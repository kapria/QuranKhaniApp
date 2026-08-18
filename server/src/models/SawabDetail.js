const mongoose = require('mongoose');

const sawabDetailSchema = new mongoose.Schema({
  khani_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Khani',
    required: [true, 'Please add a khani id'],
    unique: true,
    index: true,
  },
  details: {
    type: String,
    required: [true, 'Please add sawab details'],
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('SawabDetail', sawabDetailSchema);
