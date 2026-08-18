const express = require('express');
const { authenticate } = require('../middleware/auth');
const Notification = require('../models/Notification');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  try {
    const notifications = await Notification.find({ user_id: req.user._id })
      .sort({ created_at: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({
      user_id: req.user._id,
      read: false,
    });

    return res.status(200).json({
      status: 'success',
      data: {
        notifications,
        unread_count: unreadCount,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching notifications',
    });
  }
});

router.patch('/:id/read', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findOneAndUpdate(
      { _id: id, user_id: req.user._id },
      { read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        status: 'error',
        message: 'Notification not found',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: { notification },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while updating notification',
    });
  }
});

module.exports = router;
