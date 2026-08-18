const express = require('express');
const { body, validationResult } = require('express-validator');
const Khani = require('../models/Khani');
const KhaniParticipant = require('../models/KhaniParticipant');
const LiveDuaSession = require('../models/LiveDuaSession');
const Notification = require('../models/Notification');
const ParaAssignment = require('../models/ParaAssignment');
const SawabDetail = require('../models/SawabDetail');
const Profile = require('../models/Profile');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

const generateJoinCode = async () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }

  let attempts = 0;
  let finalCode = code;
  while (attempts < 10) {
    const existing = await Khani.findOne({ join_code: finalCode });
    if (!existing) break;
    finalCode = '';
    for (let i = 0; i < 8; i++) {
      finalCode += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    attempts++;
  }

  return finalCode;
};

const validateKhani = [
  body('title').trim().isLength({ min: 2 }).withMessage('Title is required'),
  body('start_date').isISO8601().withMessage('Valid start date is required'),
  body('start_time').matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Valid start time is required (HH:MM)'),
  body('location').optional().trim().isLength({ max: 255 }),
  body('prayer_after').isIn(['fajar', 'zohar', 'asar', 'magrib', 'isa']).withMessage('Invalid prayer time'),
  body('duration_minutes').isInt({ min: 1, max: 720 }).withMessage('Duration must be 1-720 minutes'),
];

router.post('/', authenticate, validateKhani, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { title, start_date, start_time, location, prayer_after, duration_minutes, description } = req.body;

    const joinCode = await generateJoinCode();

    const khani = await Khani.create({
      title,
      start_date: new Date(start_date),
      start_time,
      location: location || null,
      prayer_after,
      duration_minutes: duration_minutes || 60,
      description: description || null,
      created_by: req.user._id,
      join_code: joinCode,
      status: 'scheduled',
    });

    return res.status(201).json({
      status: 'success',
      message: 'Quran Khani created successfully',
      data: { khani },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while creating Quran Khani',
    });
  }
});

router.post('/:id/start', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const khani = await Khani.findById(id);
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Quran Khani not found',
      });
    }

    if (khani.created_by.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only creator can start this khani',
      });
    }

    if (khani.status === 'live') {
      return res.status(400).json({
        status: 'error',
        message: 'Khani is already live',
      });
    }

    if (!khani.join_code) {
      khani.join_code = await generateJoinCode();
    }

    khani.status = 'live';
    khani.host_id = req.user._id;
    khani.started_at = new Date();
    await khani.save();

    await KhaniParticipant.create({
      khani_id: khani._id,
      user_id: req.user._id,
      role: 'host',
    });

    return res.status(200).json({
      status: 'success',
      message: 'Quran Khani started successfully',
      data: { khani },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while starting Quran Khani',
    });
  }
});

router.post('/join', authenticate, async (req, res) => {
  try {
    const { join_code } = req.body;

    if (!join_code) {
      return res.status(400).json({
        status: 'error',
        message: 'Join code is required',
      });
    }

    const khani = await Khani.findOne({ join_code: join_code.toUpperCase() });
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid join code',
      });
    }

    if (khani.status === 'ended') {
      return res.status(400).json({
        status: 'error',
        message: 'This Quran Khani has ended',
      });
    }

    const existingParticipant = await KhaniParticipant.findOne({
      khani_id: khani._id,
      user_id: req.user._id,
    });

    if (!existingParticipant) {
      await KhaniParticipant.create({
        khani_id: khani._id,
        user_id: req.user._id,
        role: 'listener',
      });
    }

    const populated = await Khani.findById(khani._id)
      .populate('host_id', 'name member_code avatar_url')
      .populate('created_by', 'name member_code');

    return res.status(200).json({
      status: 'success',
      message: 'Joined Quran Khani successfully',
      data: { khani: populated },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while joining Quran Khani',
    });
  }
});

router.post('/:id/end', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const khani = await Khani.findById(id);
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Quran Khani not found',
      });
    }

    if (khani.host_id && khani.host_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can end this khani',
      });
    }

    if (khani.created_by.toString() !== req.user._id.toString() && 
        (!khani.host_id || khani.host_id.toString() !== req.user._id.toString())) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can end this khani',
      });
    }

    khani.status = 'ended';
    khani.ended_at = new Date();
    await khani.save();

    const participants = await KhaniParticipant.find({ khani_id: khani._id });

    const host = await Profile.findById(khani.host_id || khani.created_by);

    for (const participant of participants) {
      if (participant.user_id.toString() !== req.user._id.toString()) {
        await Notification.create({
          user_id: participant.user_id,
          khani_id: khani._id,
          type: 'khani_ended',
          title: 'Quran Khani Ended',
          message: `${host?.name || 'Host'} has ended the Quran Khani "${khani.title}"`,
          data: {
            khani_id: khani._id,
            join_code: khani.join_code,
          },
        });
      }
    }

    const liveSession = await LiveDuaSession.findOne({ khani_id: khani._id });
    if (liveSession) {
      liveSession.status = 'ended';
      liveSession.ended_at = new Date();
      await liveSession.save();
    }

    return res.status(200).json({
      status: 'success',
      message: 'Quran Khani ended successfully',
      data: { khani },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while ending Quran Khani',
    });
  }
});

router.get('/code/:join_code', async (req, res) => {
  try {
    const { join_code } = req.params;

    const khani = await Khani.findOne({ join_code: join_code.toUpperCase() })
      .populate('host_id', 'name member_code avatar_url')
      .populate('created_by', 'name member_code');

    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid join code',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: { khani },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching khani by code',
    });
  }
});

router.get('/', async (req, res) => {
  try {
    const khanis = await Khani.find({ status: 'live' })
      .populate('created_by', 'name member_code')
      .populate('host_id', 'name member_code')
      .sort({ created_at: -1 });

    const formatted = khanis.map(k => {
      const obj = k.toObject();
      obj.profiles = obj.created_by ? { name: obj.created_by.name } : null;
      if (obj.host_id) {
        obj.host_profile = { name: obj.host_id.name };
      }
      return obj;
    });

    return res.status(200).json({
      status: 'success',
      data: { khanis: formatted },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching khanis',
    });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const khani = await Khani.findById(id)
      .populate('created_by', 'name member_code')
      .populate('host_id', 'name member_code avatar_url');

    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Quran Khani not found',
      });
    }

    const assignments = await ParaAssignment.find({ khani_id: id })
      .populate('user_id', 'name member_code');

    const formattedAssignments = assignments.map(a => {
      const obj = a.toObject();
      obj.profiles = obj.user_id ? { name: obj.user_id.name, member_code: obj.user_id.member_code } : null;
      return obj;
    });

    const sawabDetails = await SawabDetail.findOne({ khani_id: id });

    const formattedKhani = khani.toObject();
    formattedKhani.profiles = khani.created_by ? { name: khani.created_by.name } : null;
    if (khani.host_id) {
      formattedKhani.host_profile = { name: khani.host_id.name };
    }

    return res.status(200).json({
      status: 'success',
      data: {
        khani: formattedKhani,
        assignments: formattedAssignments || [],
        sawabDetails: sawabDetails || null,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching khani details',
    });
  }
});

module.exports = router;
