const mongoose = require('mongoose');

const liveDuaSessionSchema = new mongoose.Schema({
  khani_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Khani',
    required: true,
    unique: true,
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
  status: {
    type: String,
    enum: ['waiting', 'live', 'ended'],
    default: 'waiting',
    index: true,
  },
  started_at: {
    type: Date,
  },
  ended_at: {
    type: Date,
  },
}, {
  timestamps: true,
});

liveDuaSessionSchema.index({ khani_id: 1 });

module.exports = mongoose.model('LiveDuaSession', liveDuaSessionSchema);
