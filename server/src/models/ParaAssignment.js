const mongoose = require('mongoose');

const paraAssignmentSchema = new mongoose.Schema({
  khani_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Khani',
    required: [true, 'Please add a khani id'],
    index: true,
  },
  para_number: {
    type: Number,
    required: [true, 'Please add a para number'],
    min: [1, 'Para number must be at least 1'],
    max: [30, 'Para number cannot exceed 30'],
  },
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: [true, 'Please add a user id'],
    index: true,
  },
  status: {
    type: String,
    enum: {
      values: ['assigned', 'completed'],
      message: 'Status must be assigned or completed',
    },
    default: 'assigned',
  },
  completed_at: {
    type: Date,
  },
}, {
  timestamps: true,
});

paraAssignmentSchema.index({ khani_id: 1, para_number: 1 }, { unique: true });
paraAssignmentSchema.index({ user_id: 1 });

module.exports = mongoose.model('ParaAssignment', paraAssignmentSchema);
