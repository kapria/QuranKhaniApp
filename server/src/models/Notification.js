const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
    index: true,
  },
  khani_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Khani',
    required: true,
    index: true,
  },
  type: {
    type: String,
    enum: ['khani_started', 'khani_ended', 'stream_started', 'stream_ended'],
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  data: {
    type: mongoose.Schema.Types.Mixed,
  },
  read: {
    type: Boolean,
    default: false,
    index: true,
  },
}, {
  timestamps: true,
});

notificationSchema.index({ user_id: 1, read: 1, created_at: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
