const express = require('express');
const { body, validationResult } = require('express-validator');
const LiveDuaSession = require('../models/LiveDuaSession');
const Khani = require('../models/Khani');
const KhaniParticipant = require('../models/KhaniParticipant');
const Profile = require('../models/Profile');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post('/start', authenticate, [
  body('join_code').notEmpty().withMessage('Join code is required'),
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

    const { join_code, stream_type } = req.body;
    const userId = req.user._id;

    const khani = await Khani.findOne({ join_code: join_code.toUpperCase() });
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid join code',
      });
    }

    if (khani.host_id && khani.host_id.toString() !== userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can start live dua',
      });
    }

    if (khani.status !== 'live') {
      return res.status(400).json({
        status: 'error',
        message: 'Quran Khani is not live',
      });
    }

    let session = await LiveDuaSession.findOne({ khani_id: khani._id });
    if (!session) {
      session = await LiveDuaSession.create({
        khani_id: khani._id,
        stream_type: stream_type || 'audio',
        status: 'waiting',
      });
    }

    const populated = await LiveDuaSession.findById(session._id)
      .populate('khani_id', 'title join_code');

    return res.status(200).json({
      status: 'success',
      message: 'Live dua session ready',
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
    const { join_code } = req.body;
    const userId = req.user._id;

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

    const isHost = khani.host_id && khani.host_id.toString() === userId.toString();
    const existingParticipant = await KhaniParticipant.findOne({
      khani_id: khani._id,
      user_id: userId,
    });

    if (!existingParticipant) {
      await KhaniParticipant.create({
        khani_id: khani._id,
        user_id: userId,
        role: isHost ? 'host' : 'listener',
      });
    }

    const liveSession = await LiveDuaSession.findOne({ khani_id: khani._id });

    const populated = await Khani.findById(khani._id)
      .populate('host_id', 'name member_code avatar_url')
      .populate('created_by', 'name member_code');

    return res.status(200).json({
      status: 'success',
      message: isHost ? 'Welcome host!' : 'Joined live dua session',
      data: {
        khani: populated,
        liveSession: liveSession || null,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while joining live dua',
    });
  }
});

router.get('/code/:join_code', async (req, res) => {
  try {
    const { join_code } = req.params;

    const khani = await Khani.findOne({ join_code: join_code.toUpperCase() })
      .populate('host_id', 'name member_code avatar_url')
      .populate('khani_id', 'title');

    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Session not found',
      });
    }

    const liveSession = await LiveDuaSession.findOne({ khani_id: khani._id });

    return res.status(200).json({
      status: 'success',
      data: {
        khani,
        liveSession,
      },
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

    const session = await LiveDuaSession.findOne({ khani_id });

    return res.status(200).json({
      status: 'success',
      data: { session },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching live session',
    });
  }
});

router.post('/code/:join_code/start', authenticate, async (req, res) => {
  try {
    const { join_code } = req.params;
    const { stream_url, stream_type } = req.body;
    const userId = req.user._id;

    const khani = await Khani.findOne({ join_code: join_code.toUpperCase() });
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid join code',
      });
    }

    if (!khani.host_id || khani.host_id.toString() !== userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can start stream',
      });
    }

    let session = await LiveDuaSession.findOne({ khani_id: khani._id });
    if (!session) {
      session = await LiveDuaSession.create({
        khani_id: khani._id,
        stream_type: stream_type || 'audio',
        status: 'waiting',
      });
    }

    session.status = 'live';
    session.stream_url = stream_url || null;
    session.started_at = new Date();
    await session.save();

    const populated = await LiveDuaSession.findById(session._id)
      .populate('khani_id', 'title join_code');

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

router.post('/code/:join_code/end', authenticate, async (req, res) => {
  try {
    const { join_code } = req.params;
    const userId = req.user._id;

    const khani = await Khani.findOne({ join_code: join_code.toUpperCase() });
    if (!khani) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid join code',
      });
    }

    if (!khani.host_id || khani.host_id.toString() !== userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only host can end the session',
      });
    }

    const session = await LiveDuaSession.findOne({ khani_id: khani._id });
    if (session) {
      session.status = 'ended';
      session.ended_at = new Date();
      await session.save();
    }

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
