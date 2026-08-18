const mongoose = require('mongoose');

const khaniParticipantSchema = new mongoose.Schema({
  khani_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Khani',
    required: true,
    index: true,
  },
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
    index: true,
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
}, {
  timestamps: true,
});

khaniParticipantSchema.index({ khani_id: 1, user_id: 1 }, { unique: true });

module.exports = mongoose.model('KhaniParticipant', khaniParticipantSchema);
