const mongoose = require('mongoose');

const liveDuaSessionSchema = new mongoose.Schema({
  khani_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Khani',
    required: true,
    index: true,
  },
  host_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
    index: true,
  },
  unique_code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    length: 8,
  },
  status: {
    type: String,
    enum: ['waiting', 'live', 'ended'],
    default: 'waiting',
    index: true,
  },
  stream_type: {
    type: String,
    enum: ['audio', 'video'],
  },
  stream_url: {
    type: String,
    trim: true,
  },
  started_at: {
    type: Date,
  },
  ended_at: {
    type: Date,
  },
  participants: [{
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Profile',
    },
    role: {
      type: String,
      enum: ['host', 'listener', 'viewer'],
      default: 'listener',
    },
    joined_at: {
      type: Date,
      default: Date.now,
    },
  }],
}, {
  timestamps: true,
});

liveDuaSessionSchema.index({ unique_code: 1 });
liveDuaSessionSchema.index({ khani_id: 1, status: 1 });
liveDuaSessionSchema.index({ host_id: 1 });

module.exports = mongoose.model('LiveDuaSession', liveDuaSessionSchema);
