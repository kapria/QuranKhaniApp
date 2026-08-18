const mongoose = require('mongoose');

const profileSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a name'],
    trim: true,
  },
  email: {
    type: String,
    unique: true,
    lowercase: true,
    sparse: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email'],
  },
  password_hash: {
    type: String,
    select: false,
    sparse: true,
  },
  phone: {
    type: String,
    trim: true,
  },
  member_code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    length: 8,
  },
  google_id: {
    type: String,
    unique: true,
    sparse: true,
  },
  avatar_url: {
    type: String,
    trim: true,
  },
  auth_provider: {
    type: String,
    enum: ['local', 'google'],
    default: 'local',
  },
}, {
  timestamps: true,
});

profileSchema.index({ email: 1 });
profileSchema.index({ member_code: 1 });
profileSchema.index({ google_id: 1 });

module.exports = mongoose.model('Profile', profileSchema);
