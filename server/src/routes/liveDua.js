const express = require('express');
const { body, validationResult } = require('express-validator');
const LiveDuaSession = require('../models/LiveDuaSession');
const Khani = require('../models/Khani');
const Profile = require('../models/Profile');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

const generateUniqueCode = async () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }

  let attempts = 0;
  let finalCode = code;
  while (attempts < 10) {
    const existing = await LiveDuaSession.findOne({ unique_code: finalCode });
    if (!existing) break;
    finalCode = '';
    for (let i = 0; i < 8; i++) {
      finalCode += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    attempts++;
  }

  return finalCode;
};

router.post('/start', authenticate, [
  body('khani_id').isMongoId().withMessage('Valid khani ID is required'),
  body('stream_type').isIn(['audio', 'video']).withMessage('Stream type must be audio or video'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { khani_id, stream_type } = req.body;
    const hostId = req.user._id;

    const khani = await Khani.findById(khani_id);
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Quran Khani not found',
      });
    }

    const existingLive = await LiveDuaSession.findOne({
      khani_id,
      status: { $in: ['waiting', 'live'] },
    });

    if (existingLive) {
      return res.status(400).json({
        status: 'error',
        message: 'Live session already exists for this Khani',
      });
    }

    const uniqueCode = await generateUniqueCode();

    const session = await LiveDuaSession.create({
      khani_id,
      host_id: hostId,
      unique_code: uniqueCode,
      status: 'waiting',
      stream_type: stream_type || 'audio',
      participants: [
        {
          user_id: hostId,
          role: 'host',
        },
      ],
    });

    const populated = await LiveDuaSession.findById(session._id)
      .populate('host_id', 'name member_code avatar_url')
      .populate('khani_id', 'title');

    return res.status(201).json({
      status: 'success',
      message: 'Live dua session created',
      data: { session: populated },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while starting live dua',
    });
  }
});

router.post('/join', authenticate, async (req, res) => {
  try {
    const { unique_code } = req.body;
    const userId = req.user._id;

    const session = await LiveDuaSession.findOne({ unique_code });

    if (!session) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid join code',
      });
    }

    if (session.status === 'ended') {
      return res.status(400).json({
        status: 'error',
        message: 'This live session has ended',
      });
    }

    const isHost = session.host_id.toString() === userId.toString();
    const existingParticipant = session.participants.find(
      (p) => p.user_id.toString() === userId.toString()
    );

    if (!existingParticipant) {
      session.participants.push({
        user_id: userId,
        role: isHost ? 'host' : 'listener',
      });
      await session.save();
    }

    const populated = await LiveDuaSession.findById(session._id)
      .populate('host_id', 'name member_code avatar_url')
      .populate('participants.user_id', 'name member_code avatar_url')
      .populate('khani_id', 'title');

    return res.status(200).json({
      status: 'success',
      message: isHost ? 'Welcome host!' : 'Joined live dua session',
      data: { session: populated },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while joining live dua',
    });
  }
});

router.get('/code/:unique_code', async (req, res) => {
  try {
    const { unique_code } = req.params;

    const session = await LiveDuaSession.findOne({ unique_code })
      .populate('host_id', 'name member_code avatar_url')
      .populate('khani_id', 'title');

    if (!session) {
      return res.status(404).json({
        status: 'error',
        message: 'Session not found',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: { session },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching session',
    });
  }
});

router.get('/khani/:khani_id', authenticate, async (req, res) => {
  try {
    const { khani_id } = req.params;

    const sessions = await LiveDuaSession.find({ khani_id })
      .populate('host_id', 'name member_code')
      .sort({ created_at: -1 });

    return res.status(200).json({
      status: 'success',
      data: { sessions },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching live sessions',
    });
  }
});

router.post('/code/:unique_code/start', authenticate, async (req, res) => {
  try {
    const { unique_code } = req.params;
    const { stream_url } = req.body;
    const userId = req.user._id;

    const session = await LiveDuaSession.findOne({ unique_code });

    if (!session) {
      return res.status(404).json({
        status: 'error',
        message: 'Session not found',
      });
    }

    if (session.host_id.toString() !== userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can start stream',
      });
    }

    session.status = 'live';
    session.stream_url = stream_url || null;
    session.started_at = new Date();
    await session.save();

    const populated = await LiveDuaSession.findById(session._id)
      .populate('host_id', 'name member_code avatar_url')
      .populate('khani_id', 'title');

    return res.status(200).json({
      status: 'success',
      message: 'Stream started',
      data: { session: populated },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while starting stream',
    });
  }
});

router.post('/code/:unique_code/end', authenticate, async (req, res) => {
  try {
    const { unique_code } = req.params;
    const userId = req.user._id;

    const session = await LiveDuaSession.findOne({ unique_code });

    if (!session) {
      return res.status(404).json({
        status: 'error',
        message: 'Session not found',
      });
    }

    if (session.host_id.toString() !== userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can end the session',
      });
    }

    session.status = 'ended';
    session.ended_at = new Date();
    await session.save();

    return res.status(200).json({
      status: 'success',
      message: 'Live dua session ended',
      data: { session },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while ending live dua',
    });
  }
});

module.exports = router;
