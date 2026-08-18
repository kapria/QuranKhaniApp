const express = require('express');
const { body, validationResult } = require('express-validator');
const ParaAssignment = require('../models/ParaAssignment');
const Khani = require('../models/Khani');
const Profile = require('../models/Profile');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

const validateAssignment = [
  body('khani_id').isMongoId().withMessage('Valid khani ID is required'),
  body('para_number').isInt({ min: 1, max: 30 }).withMessage('Para number must be between 1 and 30'),
];

router.get('/', async (req, res) => {
  try {
    const paras = await ParaAssignment.find()
      .populate('user_id', 'name member_code')
      .sort({ para_number: 1 });

    const formatted = paras.map(a => {
      const obj = a.toObject();
      obj.profiles = obj.user_id ? { name: obj.user_id.name, member_code: obj.user_id.member_code } : null;
      return obj;
    });

    return res.status(200).json({
      status: 'success',
      data: { paras: formatted },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching paras',
    });
  }
});

router.post('/assign', authenticate, validateAssignment, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { khani_id, para_number } = req.body;
    const userId = req.user._id;

    const existing = await ParaAssignment.findOne({ khani_id, para_number });
    if (existing) {
      return res.status(400).json({
        status: 'error',
        message: 'This para is already assigned',
      });
    }

    const assignment = await ParaAssignment.create({
      khani_id,
      para_number,
      user_id: userId,
      status: 'assigned',
    });

    const populated = await ParaAssignment.findById(assignment._id)
      .populate('user_id', 'name member_code');

    const formatted = populated.toObject();
    formatted.profiles = populated.user_id ? { name: populated.user_id.name, member_code: populated.user_id.member_code } : null;

    return res.status(201).json({
      status: 'success',
      message: 'Para assigned successfully',
      data: { assignment: formatted },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while assigning para',
    });
  }
});

router.patch('/:id/complete', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const assignment = await ParaAssignment.findByIdAndUpdate(
      id,
      { status: 'completed', completed_at: new Date() },
      { new: true }
    ).populate('user_id', 'name member_code');

    if (!assignment) {
      return res.status(404).json({
        status: 'error',
        message: 'Para assignment not found',
      });
    }

    const formatted = assignment.toObject();
    formatted.profiles = assignment.user_id ? { name: assignment.user_id.name, member_code: assignment.user_id.member_code } : null;

    return res.status(200).json({
      status: 'success',
      message: 'Para marked as completed',
      data: { assignment: formatted },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while completing para',
    });
  }
});

router.get('/my-assignments', authenticate, async (req, res) => {
  try {
    const userId = req.user._id;

    const assignments = await ParaAssignment.find({ user_id: userId })
      .populate('khani_id', 'title start_date start_time prayer_after duration_days is_active')
      .sort({ created_at: -1 });

    return res.status(200).json({
      status: 'success',
      data: { assignments },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching assignments',
    });
  }
});

module.exports = router;
