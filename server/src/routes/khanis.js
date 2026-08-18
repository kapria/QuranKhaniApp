const express = require('express');
const { body, validationResult } = require('express-validator');
const Khani = require('../models/Khani');
const ParaAssignment = require('../models/ParaAssignment');
const SawabDetail = require('../models/SawabDetail');
const Profile = require('../models/Profile');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

const validateKhani = [
  body('title').trim().isLength({ min: 2 }).withMessage('Title is required'),
  body('start_date').isISO8601().withMessage('Valid start date is required'),
  body('start_time').matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Valid start time is required (HH:MM)'),
  body('location').optional().trim().isLength({ max: 255 }),
  body('prayer_after').isIn(['fajar', 'zohar', 'asar', 'magrib', 'isa']).withMessage('Invalid prayer time'),
  body('duration_days').isInt({ min: 1, max: 30 }).withMessage('Duration must be 1-30 days'),
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

    const { title, start_date, start_time, location, prayer_after, duration_days, description } = req.body;

    const khani = await Khani.create({
      title,
      start_date: new Date(start_date),
      start_time,
      location: location || null,
      prayer_after,
      duration_days,
      description: description || null,
      created_by: req.user._id,
      is_active: true,
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

router.get('/', async (req, res) => {
  try {
    const khanis = await Khani.find({ is_active: true })
      .populate('created_by', 'name member_code')
      .sort({ created_at: -1 });

    const formatted = khanis.map(k => {
      const obj = k.toObject();
      obj.profiles = obj.created_by ? { name: obj.created_by.name } : null;
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

    const khani = await Khani.findById(id).populate('created_by', 'name member_code');
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

    if (khani.created_by.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only creator can end this khani',
      });
    }

    const updated = await Khani.findByIdAndUpdate(
      id,
      { is_active: false, ended_at: new Date() },
      { new: true }
    );

    return res.status(200).json({
      status: 'success',
      message: 'Quran Khani ended successfully',
      data: { khani: updated },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while ending Quran Khani',
    });
  }
});

module.exports = router;
