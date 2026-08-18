const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const bcrypt = require('bcrypt');
const Profile = require('../models/Profile');

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

const verifyGoogleToken = async (idToken) => {
  const response = await axios.get(
    `https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`
  );
  return response.data;
};

router.post('/google', async (req, res) => {
  try {
    const { id_token } = req.body;

    if (!id_token) {
      return res.status(400).json({
        status: 'error',
        message: 'Google ID token is required',
      });
    }

    let googleUser;
    try {
      googleUser = await verifyGoogleToken(id_token);
    } catch (error) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid Google token',
      });
    }

    if (!googleUser.email_verified) {
      return res.status(400).json({
        status: 'error',
        message: 'Email not verified with Google',
      });
    }

    let user = await Profile.findOne({ google_id: googleUser.sub });

    if (!user) {
      const existingEmail = await Profile.findOne({ email: googleUser.email });
      if (existingEmail) {
        return res.status(400).json({
          status: 'error',
          message: 'Email already registered with another method',
        });
      }

      const memberCode = await generateMemberCode();

      user = await Profile.create({
        name: googleUser.name,
        email: googleUser.email,
        google_id: googleUser.sub,
        avatar_url: googleUser.picture || null,
        member_code: memberCode,
        auth_provider: 'google',
        password_hash: null,
      });
    } else {
      if (!user.name && googleUser.name) {
        user.name = googleUser.name;
      }
      if (!user.avatar_url && googleUser.picture) {
        user.avatar_url = googleUser.picture;
      }
      await user.save();
    }

    const token = generateToken(user._id.toString());

    const userWithoutPassword = user.toObject();
    delete userWithoutPassword.password_hash;

    return res.status(200).json({
      status: 'success',
      message: user.google_id ? 'Google login successful' : 'Account linked',
      data: {
        user: userWithoutPassword,
        token,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error during Google authentication',
    });
  }
});

router.post('/link-google', authenticate, async (req, res) => {
  try {
    const { id_token } = req.body;
    const userId = req.user._id;

    if (!id_token) {
      return res.status(400).json({
        status: 'error',
        message: 'Google ID token is required',
      });
    }

    let googleUser;
    try {
      googleUser = await verifyGoogleToken(id_token);
    } catch (error) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid Google token',
      });
    }

    const existingGoogleUser = await Profile.findOne({ google_id: googleUser.sub });
    if (existingGoogleUser && existingGoogleUser._id.toString() !== userId.toString()) {
      return res.status(400).json({
        status: 'error',
        message: 'This Google account is already linked to another user',
      });
    }

    const user = await Profile.findByIdAndUpdate(
      userId,
      {
        google_id: googleUser.sub,
        avatar_url: googleUser.picture || req.user.avatar_url,
        auth_provider: 'google',
      },
      { new: true }
    );

    const userWithoutPassword = user.toObject();
    delete userWithoutPassword.password_hash;

    return res.status(200).json({
      status: 'success',
      message: 'Google account linked successfully',
      data: { user: userWithoutPassword },
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error while linking Google account',
    });
  }
});

module.exports = router;
