# Quran Khani - MongoDB Setup

This project uses MongoDB as the database.

## Prerequisites

- MongoDB 4.4+ (local or Atlas)
- Node.js 18+

## Environment Variables

Update `.env` with your MongoDB connection string and Google OAuth credentials:

```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/quran_khani
JWT_SECRET=your-jwt-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
```

For MongoDB Atlas:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/quran_khani
```

## Database Setup

Mongoose models define the schema:
- `src/models/Profile.js` - Users with Google OAuth support
- `src/models/Khani.js` - Quran Khani events
- `src/models/ParaAssignment.js` - Para assignments
- `src/models/SawabDetail.js` - Essalay Sawab details
- `src/models/LiveDuaSession.js` - Live streaming sessions

Indexes are automatically created by Mongoose on connection.

### Run Setup Script

```bash
npm run setup-db
```

## Run the Server

```bash
npm install
npm run dev
```

## API Endpoints

### Auth
- `POST /api/auth/register` - Register with email/password
- `POST /api/auth/login` - Login
- `GET /api/auth/profile` - Get profile
- `POST /api/auth/oauth/google` - Google OAuth login
- `POST /api/auth/oauth/link-google` - Link Google account (auth required)

### Khanis
- `POST /api/khanis` - Create Quran Khani
- `GET /api/khanis` - List active khanis
- `GET /api/khanis/:id` - Get khani details with assignments
- `POST /api/khanis/:id/end` - End a khani

### Paras
- `GET /api/paras` - Get all para assignments
- `POST /api/paras/assign` - Assign a para
- `POST /api/paras/:id/complete` - Mark para as completed
- `GET /api/paras/my-assignments` - Get my assignments

### Sawab Details
- `POST /api/sawab` - Save sawab details
- `GET /api/sawab/:khani_id` - Get sawab details

### Live Dua
- `POST /api/live-dua/start` - Start live dua session (auth required)
- `POST /api/live-dua/join` - Join with unique code (auth required)
- `GET /api/live-dua/code/:unique_code` - Get session by code
- `POST /api/live-dua/code/:unique_code/start` - Host starts stream
- `POST /api/live-dua/code/:unique_code/end` - Host ends session
