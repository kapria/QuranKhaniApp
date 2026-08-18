const express = require('express');
const { body, validationResult } = require('express-validator');
const SawabDetail = require('../models/SawabDetail');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

const validateSawab = [
  body('khani_id').isMongoId().withMessage('Valid khani ID is required'),
  body('details').trim().isLength({ min: 1 }).withMessage('Details are required'),
];

router.post('/', authenticate, validateSawab, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { khani_id, details } = req.body;

    const existing = await SawabDetail.findOne({ khani_id });
    let result;

    if (existing) {
      result = await SawabDetail.findByIdAndUpdate(
        existing._id,
        { details, updated_at: new Date() },
        { new: true }
      );
    } else {
      result = await SawabDetail.create({
        khani_id,
        details,
      });
    }

    return res.status(200).json({
      status: 'success',
      message: existing ? 'Sawab details updated' : 'Sawab details created',
      data: { sawabDetails: result },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while saving sawab details',
    });
  }
});

router.get('/:khani_id', async (req, res) => {
  try {
    const { khani_id } = req.params;

    const sawabDetails = await SawabDetail.findOne({ khani_id });

    return res.status(200).json({
      status: 'success',
      data: { sawabDetails: sawabDetails || null },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while fetching sawab details',
    });
  }
});

module.exports = router;
