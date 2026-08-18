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
  duration_minutes: {
    type: Number,
    required: [true, 'Please add duration in minutes'],
    min: [1, 'Duration must be at least 1 minute'],
    max: [720, 'Duration cannot exceed 720 minutes (12 hours)'],
    default: 60,
  },
  description: {
    type: String,
    trim: true,
  },
  join_code: {
    type: String,
    unique: true,
    uppercase: true,
    length: 8,
  },
  host_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    index: true,
  },
  status: {
    type: String,
    enum: ['scheduled', 'live', 'ended'],
    default: 'scheduled',
    index: true,
  },
  started_at: {
    type: Date,
  },
  ended_at: {
    type: Date,
  },
  created_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Profile',
    required: true,
  },
}, {
  timestamps: true,
});

khaniSchema.index({ join_code: 1 });
khaniSchema.index({ host_id: 1 });
khaniSchema.index({ status: 1, created_at: -1 });
khaniSchema.index({ created_by: 1 });

module.exports = mongoose.model('Khani', khaniSchema);
