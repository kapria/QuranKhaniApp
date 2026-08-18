const jwt = require('jsonwebtoken');
const Profile = require('../models/Profile');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        status: 'error',
        message: 'No token provided',
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await Profile.findById(decoded.userId).select('-password_hash');

    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid token',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Authentication failed',
    });
  }
};

module.exports = { authenticate };
