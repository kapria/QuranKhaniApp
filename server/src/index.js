require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB } = require('./config/mongodb');
const authRoutes = require('./routes/auth');
const authOAuthRoutes = require('./routes/authOAuth');
const khanisRoutes = require('./routes/khanis');
const parasRoutes = require('./routes/paras');
const sawabRoutes = require('./routes/sawab');
const liveDuaRoutes = require('./routes/liveDua');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Quran Khani API is running' });
});

app.use('/api/auth', authRoutes);
app.use('/api/auth/oauth', authOAuthRoutes);
app.use('/api/khanis', khanisRoutes);
app.use('/api/paras', parasRoutes);
app.use('/api/sawab', sawabRoutes);
app.use('/api/live-dua', liveDuaRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    status: 'error',
    message: err.message || 'Internal server error',
  });
});

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  await connectDB();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
};

startServer();
