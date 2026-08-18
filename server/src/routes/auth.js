const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const Profile = require('../models/Profile');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

const generateMemberCode = async () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }

  let attempts = 0;
  let finalCode = code;
  while (attempts < 10) {
    const existing = await Profile.findOne({ member_code: finalCode });
    if (!existing) break;
    finalCode = '';
    for (let i = 0; i < 8; i++) {
      finalCode += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    attempts++;
  }

  return finalCode;
};

const validateRegister = [
  body('name').trim().isLength({ min: 2 }).withMessage('Name is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('phone').optional().isMobilePhone(),
];

const validateLogin = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required'),
];

router.post('/register', validateRegister, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { name, email, password, phone } = req.body;

    const existingUser = await Profile.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'User already exists with this email',
      });
    }

    const memberCode = await generateMemberCode();
    const hashedPassword = await bcrypt.hash(password, 12);

    const user = await Profile.create({
      name,
      email,
      password_hash: hashedPassword,
      phone: phone || null,
      member_code: memberCode,
    });

    const token = generateToken(user._id.toString());

    const userWithoutPassword = user.toObject();
    delete userWithoutPassword.password_hash;

    return res.status(201).json({
      status: 'success',
      message: 'User registered successfully',
      data: {
        user: userWithoutPassword,
        token,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error during registration',
    });
  }
});

router.post('/login', validateLogin, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { email, password } = req.body;

    const user = await Profile.findOne({ email }).select('+password_hash');
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password',
      });
    }

    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password',
      });
    }

    const token = generateToken(user._id.toString());

    const userWithoutPassword = user.toObject();
    delete userWithoutPassword.password_hash;

    return res.status(200).json({
      status: 'success',
      message: 'Login successful',
      data: {
        user: userWithoutPassword,
        token,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error during login',
    });
  }
});

router.get('/profile', authenticate, async (req, res) => {
  try {
    const userWithoutPassword = req.user.toObject();
    delete userWithoutPassword.password_hash;

    return res.status(200).json({
      status: 'success',
      data: { user: userWithoutPassword },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch profile',
    });
  }
});

module.exports = router;
