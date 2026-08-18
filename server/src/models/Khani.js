const mongoose = require('mongoose');

const khaniSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title'],
    trim: true,
  },
  start_date: {
    type: Date,
    required: [true, 'Please add a start date'],
  },
  start_time: {
    type: String,
    required: [true, 'Please add a start time'],
    match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Please enter a valid time (HH:MM)'],
  },
  location: {
    type: String,
    trim: true,
  },
  prayer_after: {
    type: String,
    required: [true, 'Please specify prayer time'],
    enum: {
      values: ['fajar', 'zohar', 'asar', 'magrib', 'isa'],
      message: 'Prayer time must be: fajar, zohar, asar, magrib, or isa',
    },
  },
  duration_days: {
    type: Number,
    required: [true, 'Please add duration'],
    min: [1, 'Duration must be at least 1 day'],
    max: [30, 'Duration cannot exceed 30 days'],
    default: 30,
  },
  description: {
    type: String,
    trim: true,
  },
  is_active: {
    type: Boolean,
    default: true,
  },
  created_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
  },
  ended_at: {
    type: Date,
  },
}, {
  timestamps: true,
});

khaniSchema.index({ created_by: 1 });
khaniSchema.index({ is_active: 1 });
khaniSchema.index({ created_at: -1 });

module.exports = mongoose.model('Khani', khaniSchema);
