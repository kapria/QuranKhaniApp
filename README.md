# Quran Khani - Full Stack Application

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)

A comprehensive **Quran Khani management system** with a Flutter mobile application and a Node.js/Express backend. The platform enables community members to organize Quran recitation events (Khanis), manage para assignments, track completion progress, and connect through live dua sessions with real-time streaming support.

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [System Architecture](#system-architecture)
4. [Technology Stack](#technology-stack)
5. [Database Schema](#database-schema)
6. [Project Structure](#project-structure)
7. [Getting Started](#getting-started)
8. [Environment Variables](#environment-variables)
9. [API Documentation](#api-documentation)
10. [Flutter Screens](#flutter-screens)
11. [Authentication & Security](#authentication--security)
12. [Live Dua Streaming Flow](#live-dua-streaming-flow)
13. [Troubleshooting](#troubleshooting)
---

## Overview

Quran Khani is designed to facilitate organized group recitations of the Holy Quran. The application streamlines the entire lifecycle:

- **Member onboarding** with unique identification codes
- **Event creation** for Quran Khani sessions with date, time, location, and prayer timing
- **Para distribution** across 30 paras with status tracking
- **Progress visibility** for duration and completion
- **Essalay Sawab** documentation for each Khani
- **Live dua sessions** with host/client roles and audio/video streaming support
- **Third-party authentication** via Google OAuth

---

## Key Features

### Member Management
- **Registration & Login**: Email/password with unique 8-character member code
- **Google Sign-In**: One-tap authentication using Google OAuth
- **Profile Management**: View member code, name, email, and avatar
- **Secure Authentication**: JWT-based access with bcrypt password hashing

### Quran Khani Events
- **Create Khani**: Set title, start date/time, location, prayer after (Fajar/Zohar/Asar/Magrib/Isha), and duration in minutes (1–720)
- **Unique Join Code**: Every Khani gets an 8-character join code when started
- **Host Role**: The person who starts the Khani becomes the host
- **Session States**: Scheduled → Live → Ended
- **End Khani**: Host can end the session; all joined members receive push notifications
- **Event Details**: See full metadata, assignments, sawab details, and join code in one place

### Para Assignment System
- **30 Para Grid**: Visual grid showing Para 1 through Para 30
- **Smart Assignment**: Members pick available paras; assigned paras become readonly for others
- **Completion Tracking**: Mark assigned paras as completed with visual indicators
- **Readonly Indicators**: Completed paras show green checkmarks; assigned paras show orange pending state
- **Unassigned State**: Gray buttons for available paras

### Essalay Sawab Details
- **Per-Khani Documentation**: Save and update sawab details for each Khani
- **Persistent Storage**: Details persist across app restarts and are visible to all members
- **Edit Support**: Update existing sawab details anytime during the Khani

### Live Dua Streaming
- **Unified Join Code**: Uses the same Khani join code — no separate session codes
- **Audio/Video Support**: Host chooses audio-only or video stream type
- **Client Join**: Members join using the Khani join code
- **Stream Controls**: Host can start stream with RTMP/WebRTC URL and end session
- **Status Indicators**: Waiting / Live / Ended states with clear UI feedback
- **Share Functionality**: Copy join code to clipboard for easy sharing

### Push Notifications
- **Khani Ended Notification**: All participants receive a notification when the host ends a Khani
- **In-App Notification Center**: View all notifications with read/unread status
- **Notification Types**: Khani started, khani ended, stream started, stream ended

### Duration Tracking
- **Duration in Minutes**: Total duration is configured in minutes (not days)
- **Timer Display**: Live countdown showing remaining minutes during an active session
- **End Condition**: Host can end manually when time is up or dua is complete

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │  Khanis  │  │  Paras   │  │ Live Dua│   │
│  │Provider  │  │Provider  │  │Provider  │  │Provider  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │             │             │          │
│  ┌────┴─────────────┴─────────────┴─────────────┴─────┐   │
│  │                 ApiService (HTTP)                   │   │
│  └──────────────────────────┬──────────────────────────┘   │
└─────────────────────────────┼─────────────────────────────┘
                              │ HTTPS/JSON
                              │
┌─────────────────────────────┼─────────────────────────────┐
│                    Node.js / Express Backend              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ Auth Routes  │  │ Khanis Routes│  │ Live Dua    │    │
│  │  (JWT +      │  │ (CRUD +      │  │ Routes      │    │
│  │   Google)    │  │  End)        │  │ (Sessions)  │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                  │            │
│  ┌──────┴─────────────────┴──────────────────┴───────┐    │
│  │              Controllers / Services                 │    │
│  └──────────────────────────┬──────────────────────────┘   │
│                             │                              │
│  ┌──────────────────────────┴──────────────────────────┐   │
│  │              Mongoose Models                         │   │
│  │  Profile │ Khani │ ParaAssignment │ SawabDetail      │   │
│  │  LiveDuaSession                                       │   │
│  └──────────────────────────┬──────────────────────────┘   │
└─────────────────────────────┼─────────────────────────────┘
                              │
                              │ Mongoose ODM
                              │
┌─────────────────────────────┼─────────────────────────────┐
│                         MongoDB                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │ profiles │ │ khanis   │ │para_     │ │sawab_    │     │
│  │          │ │          │ │assignments│ │details   │     │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
│  ┌───────────────────────────────────────────────────┐    │
│  │              live_dua_sessions                    │    │
│  └───────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Backend
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Runtime | Node.js 18+ | Server-side JavaScript execution |
| Framework | Express.js 4.18 | RESTful API server |
| Database | MongoDB | Document storage |
| ODM | Mongoose 8.2 | Schema modeling and validation |
| Authentication | JWT + bcrypt | Secure token-based auth |
| Third-party Auth | Google OAuth 2.0 | Social login |
| Validation | express-validator | Input validation |
| Utilities | uuid | Unique code generation |

### Frontend
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flutter 3.10+ | Cross-platform mobile app |
| Language | Dart | Programming language |
| State Management | Provider 6.1 | Reactive state handling |
| Networking | HTTP | REST API communication |
| Storage | SharedPreferences | Local token/user storage |
| Google Sign-In | google_sign_in 6.2 | OAuth authentication |
| Icons | Material Icons | UI iconography |

---

## Database Schema

### profiles
Stores user information including local and Google-authenticated accounts.

```javascript
{
  _id: ObjectId,
  name: String,              // Required
  email: String,             // Unique, sparse (for local accounts)
  password_hash: String,     // Sparse (null for Google-only users)
  phone: String,             // Optional
  member_code: String,       // Unique 8-char code (ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789)
  google_id: String,         // Google sub ID, sparse
  avatar_url: String,        // Google profile picture
  auth_provider: String,     // "local" | "google"
  created_at: Date,
  updated_at: Date
}
```

**Indexes**: `email`, `member_code`, `google_id`

### khanis
Quran Khani event definitions. The join_code is generated when the host starts the Khani.

```javascript
{
  _id: ObjectId,
  title: String,             // Required
  start_date: Date,          // Event start date
  start_time: String,        // HH:MM format
  location: String,          // Optional venue
  prayer_after: String,      // fajar | zohar | asar | magrib | isa
  duration_minutes: Number,  // 1-720, default 60
  description: String,       // Optional details
  join_code: String,         // 8-char unique code for joining
  host_id: ObjectId,         // Reference to Profile (set when started)
  status: String,            // "scheduled" | "live" | "ended"
  started_at: Date,          // Set when host starts
  ended_at: Date,            // Set when host ends
  created_by: ObjectId,      // Reference to Profile
  created_at: Date
}
```

**Indexes**: `join_code` (unique), `host_id`, `status`, `created_by`

### para_assignments
Tracks which member picked which para for which Khani.

```javascript
{
  _id: ObjectId,
  khani_id: ObjectId,        // Reference to Khani
  para_number: Number,       // 1-30
  user_id: ObjectId,         // Reference to Profile
  status: String,            // "assigned" | "completed"
  completed_at: Date,        // Set when completed
  created_at: Date
}
```

**Indexes**: Compound unique `(khani_id, para_number)`, `user_id`

### sawab_details
Essalay Sawab text per Khani.

```javascript
{
  _id: ObjectId,
  khani_id: ObjectId,        // Reference to Khani, unique
  details: String,           // Sawab description
  created_at: Date,
  updated_at: Date
}
```

**Indexes**: `khani_id`

### khani_participants
Tracks who has joined a Khani session.

```javascript
{
  _id: ObjectId,
  khani_id: ObjectId,        // Reference to Khani
  user_id: ObjectId,         // Reference to Profile
  role: String,              // "host" | "listener"
  joined_at: Date
}
```

**Indexes**: `(khani_id, user_id)` unique

### live_dua_sessions
Live streaming state per Khani. One session per Khani.

```javascript
{
  _id: ObjectId,
  khani_id: ObjectId,        // Reference to Khani, unique
  stream_type: String,       // "audio" | "video"
  stream_url: String,        // RTMP/WebRTC/HLS URL
  status: String,            // "waiting" | "live" | "ended"
  started_at: Date,
  ended_at: Date,
  created_at: Date
}
```

**Indexes**: `khani_id` (unique)

### notifications
Push notifications for Khani events.

```javascript
{
  _id: ObjectId,
  user_id: ObjectId,         // Reference to Profile
  khani_id: ObjectId,        // Reference to Khani
  type: String,              // "khani_started" | "khani_ended" | "stream_started" | "stream_ended"
  title: String,             // Notification title
  message: String,           // Notification body
  data: Mixed,               // Additional payload (khani_id, join_code)
  read: Boolean,             // Read status
  created_at: Date
}
```

**Indexes**: `(user_id, read, created_at)`

---

## Project Structure

```
QuranKhaniApp/
├── README.md                 # This file
│
├── server/                   # Backend API
│   ├── .env                  # Environment variables
│   ├── .env.example          # Environment template
│   ├── .gitignore
│   ├── package.json
│   ├── README.md             # Backend-specific documentation
│   ├── test/
│   │   └── api.test.js       # Health check test script
│   ├── scripts/
│   │   └── setup-db.js       # MongoDB connection verifier
│   └── src/
│       ├── config/
│       │   └── mongodb.js    # Mongoose connection setup
│       ├── middleware/
│       │   └── auth.js       # JWT authentication middleware
│       ├── models/
│       │   ├── Profile.js
│       │   ├── Khani.js
│       │   ├── ParaAssignment.js
│       │   ├── SawabDetail.js
│       │   ├── LiveDuaSession.js
│       │   ├── KhaniParticipant.js
│       │   └── Notification.js
│       ├── routes/
│       │   ├── auth.js       # /api/auth/*
│       │   ├── authOAuth.js  # /api/auth/oauth/*
│       │   ├── khanis.js     # /api/khanis/*
│       │   ├── paras.js      # /api/paras/*
│       │   ├── sawab.js      # /api/sawab/*
│       │   ├── liveDua.js    # /api/live-dua/*
│       │   └── notifications.js # /api/notifications/*
│       └── index.js          # Express app entry point
│
└── flutter_app/              # Flutter mobile application
    ├── .gitignore
    ├── pubspec.yaml
    └── lib/
        ├── config/
        │   └── app_config.dart      # API base URL config
        ├── main.dart                # App entry and routing
        ├── models/
        │   └── app_models.dart      # Dart data models
        ├── providers/
        │   ├── auth_provider.dart   # Auth state management
        │   └── khani_provider.dart  # Khani/LiveDua state
        ├── screens/
        │   ├── login_screen.dart
        │   ├── register_screen.dart
        │   ├── dashboard_screen.dart
        │   ├── khani_list_screen.dart
        │   ├── khani_details_screen.dart
        │   ├── para_selection_screen.dart
        │   ├── live_dua_home_screen.dart
        │   ├── start_live_dua_screen.dart
        │   ├── join_live_dua_screen.dart
        │   ├── live_dua_session_screen.dart
        │   └── notifications_screen.dart
        └── services/
            ├── api_service.dart           # HTTP client
            ├── google_sign_in_service.dart # Google OAuth helper
```

---

## Getting Started

### Prerequisites

- **Node.js** 18.x or higher
- **npm** 9.x or higher
- **MongoDB** 4.4+ (local installation or MongoDB Atlas)
- **Flutter** 3.10.x or higher
- **Dart** 3.0.x or higher
- **Google OAuth** credentials (optional, for Google Sign-In)

---

### Backend Setup

1. **Navigate to the server directory:**
   ```bash
   cd server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your settings (see [Environment Variables](#environment-variables) section).

4. **Verify MongoDB connection:**
   ```bash
   npm run setup-db
   ```
   This script connects to MongoDB and verifies the connection. Collections and indexes are created automatically by Mongoose on first connection.

5. **Start the development server:**
   ```bash
   npm run dev
   ```
   The server starts on `http://localhost:3000` by default.

---

### Flutter App Setup

1. **Navigate to the Flutter app directory:**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API configuration:**
   
   Open `lib/config/app_config.dart` and update the `apiBaseUrl` to point to your backend:
   ```dart
   static const String apiBaseUrl = 'http://your-server-ip:3000/api';
   ```

4. **Configure Google Sign-In (optional):**

   - **Android**: Add `google-services.json` to `android/app/`
   - **iOS**: Add `GoogleService-Info.plist` to `ios/Runner/`

   Update the Google Client ID in `server/.env`:
   ```env
   GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
   ```

5. **Run the application:**
   ```bash
   flutter run
   ```

---

## Environment Variables

### Server (`.env`)

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `PORT` | Server port | No | `3000` |
| `NODE_ENV` | Environment mode | No | `development` |
| `MONGODB_URI` | MongoDB connection string | **Yes** | `mongodb://localhost:27017/quran_khani` |
| `JWT_SECRET` | Secret key for JWT signing | **Yes** | — |
| `GOOGLE_CLIENT_ID` | Google OAuth Client ID | No (for Google login) | — |

#### MongoDB URI Examples

**Local MongoDB:**
```
MONGODB_URI=mongodb://localhost:27017/quran_khani
```

**MongoDB Atlas:**
```
MONGODB_URI=mongodb+srv://username:password@cluster0.mongodb.net/quran_khani?retryWrites=true&w=majority
```

### Flutter (`lib/config/app_config.dart`)

| Constant | Description | Default |
|----------|-------------|---------|
| `apiBaseUrl` | Backend API base URL | `http://localhost:3000/api` |

---

## API Documentation

Base URL: `http://localhost:3000/api`

All authenticated endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

---

### Authentication Endpoints

#### Register a New Member
```http
POST /api/auth/register
```

**Request Body:**
```json
{
  "name": "Ahmad Ali",
  "email": "ahmad@example.com",
  "password": "securePass123",
  "phone": "+923001234567"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "64b...",
      "name": "Ahmad Ali",
      "email": "ahmad@example.com",
      "phone": "+923001234567",
      "member_code": "A7X9K2M4",
      "auth_provider": "local",
      "created_at": "2024-01-15T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

#### Login
```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "ahmad@example.com",
  "password": "securePass123"
}
```

**Response:** Same structure as register, returns JWT token and user profile.

---

#### Get Current Profile
```http
GET /api/auth/profile
```

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "64b...",
      "name": "Ahmad Ali",
      "email": "ahmad@example.com",
      "member_code": "A7X9K2M4",
      "auth_provider": "local"
    }
  }
}
```

---

#### Google OAuth Login
```http
POST /api/auth/oauth/google
```

**Request Body:**
```json
{
  "id_token": "google-id-token-from-client"
}
```

**Response:** Same as register/login. If Google account already linked, returns existing user. If email exists with local account, returns error.

---

#### Link Google Account
```http
POST /api/auth/oauth/link-google
```

**Headers:** `Authorization: Bearer <token>`

Links a Google account to an existing local account.

---

### Khanis Endpoints

#### Create Quran Khani
```http
POST /api/khanis
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Monthly Quran Khani - January",
  "start_date": "2024-01-15",
  "start_time": "06:30",
  "location": "Main Hall, Community Center",
  "prayer_after": "fajar",
  "duration_minutes": 60,
  "description": "Recitation of entire Quran with tafseer"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Quran Khani created successfully",
  "data": {
    "khani": {
      "id": "64c...",
      "title": "Monthly Quran Khani - January",
      "start_date": "2024-01-15T00:00:00.000Z",
      "start_time": "06:30",
      "location": "Main Hall, Community Center",
      "prayer_after": "fajar",
      "duration_minutes": 60,
      "join_code": "KJ7H4G2F",
      "status": "scheduled",
      "created_by": "64b...",
      "created_at": "2024-01-15T08:00:00.000Z"
    }
  }
}
```

---

#### Start Quran Khani (Host)
```http
POST /api/khanis/:id/start
```

**Headers:** `Authorization: Bearer <token>`

Changes status from `scheduled` to `live`, sets `host_id` and `started_at`, and generates `join_code` if not already set.

---

#### Join Quran Khani
```http
POST /api/khanis/join
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "join_code": "KJ7H4G2F"
}
```

Adds the user as a participant in the Khani.

---

#### Get Khani by Join Code
```http
GET /api/khanis/code/:join_code
```

Public endpoint — no authentication required. Returns the Khani details for a given join code.

---

#### List Live Khanis
```http
GET /api/khanis
```

Returns all Khanis with `status: "live"`.

**Response:**
```json
{
  "status": "success",
  "data": {
    "khanis": [
      {
        "id": "64c...",
        "title": "Monthly Quran Khani - January",
        "start_date": "2024-01-15",
        "start_time": "06:30",
        "location": "Main Hall",
        "prayer_after": "fajar",
        "duration_minutes": 60,
        "join_code": "KJ7H4G2F",
        "status": "live",
        "host_id": "64b...",
        "profiles": { "name": "Ahmad Ali" },
        "host_profile": { "name": "Host Name" }
      }
    ]
  }
}
```

---

#### Get Khani Details
```http
GET /api/khanis/:id
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "khani": { /* full khani object with join_code, status, host info */ },
    "assignments": [
      {
        "id": "64d...",
        "para_number": 1,
        "status": "assigned",
        "profiles": {
          "name": "Muhammad Khan",
          "member_code": "B8Y3L5N1"
        }
      }
    ],
    "sawabDetails": {
      "id": "64e...",
      "khani_id": "64c...",
      "details": "Sawab dedicated to all participants..."
    }
  }
}
```

---

#### End Quran Khani
```http
POST /api/khanis/:id/end
```

**Headers:** `Authorization: Bearer <token>`

Only the host or creator can end the Khani. This creates notifications for all participants.

---

### Paras Endpoints

#### Assign a Para
```http
POST /api/paras/assign
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "khani_id": "64c...",
  "para_number": 5
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Para assigned successfully",
  "data": {
    "assignment": {
      "id": "64f...",
      "khani_id": "64c...",
      "para_number": 5,
      "status": "assigned",
      "profiles": {
        "name": "Ahmad Ali",
        "member_code": "A7X9K2M4"
      }
    }
  }
}
```

---

#### Complete a Para
```http
PATCH /api/paras/:id/complete
```

**Headers:** `Authorization: Bearer <token>`

Marks the assignment as completed with current timestamp.

---

#### Get My Assignments
```http
GET /api/paras/my-assignments
```

**Headers:** `Authorization: Bearer <token>`

Returns all para assignments for the authenticated user.

---

### Sawab Details Endpoints

#### Save/Update Sawab Details
```http
POST /api/sawab
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "khani_id": "64c...",
  "details": "Sawab for the peace and health of all participants..."
}
```

Creates or updates the sawab details for the given Khani.

---

#### Get Sawab Details
```http
GET /api/sawab/:khani_id
```

---

### Live Dua Endpoints

#### Start Live Dua Session (Host)
```http
POST /api/live-dua/start
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "join_code": "KJ7H4G2F",
  "stream_type": "audio"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Live dua session ready",
  "data": {
    "session": {
      "id": "650...",
      "khani_id": "64c...",
      "stream_type": "audio",
      "status": "waiting",
      "created_at": "2024-01-20T14:00:00.000Z"
    }
  }
}
```

---

#### Join Live Dua Session
```http
POST /api/live-dua/join
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "join_code": "KJ7H4G2F"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Joined live dua session",
  "data": {
    "khani": { /* populated khani object */ },
    "liveSession": { /* live dua session object */ }
  }
}
```

---

#### Get Session by Join Code
```http
GET /api/live-dua/code/:join_code
```

Public endpoint — no authentication required.

---

#### Start Stream (Host Only)
```http
POST /api/live-dua/code/:join_code/start
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "stream_url": "rtmp://stream.server.com/live/stream-key",
  "stream_type": "audio"
}
```

Changes session status from `waiting` to `live`.

---

#### End Session (Host Only)
```http
POST /api/live-dua/code/:join_code/end
```

**Headers:** `Authorization: Bearer <token>`

Changes session status to `ended`.

---

### Notifications Endpoints

#### Get My Notifications
```http
GET /api/notifications
```

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": "success",
  "data": {
    "notifications": [
      {
        "id": "651...",
        "user_id": "64b...",
        "khani_id": "64c...",
        "type": "khani_ended",
        "title": "Quran Khani Ended",
        "message": "Host Name has ended the Quran Khani \"Title\"",
        "data": {
          "khani_id": "64c...",
          "join_code": "KJ7H4G2F"
        },
        "read": false,
        "created_at": "2024-01-20T15:00:00.000Z"
      }
    ],
    "unread_count": 1
  }
}
```

---

#### Mark Notification as Read
```http
PATCH /api/notifications/:id/read
```

**Headers:** `Authorization: Bearer <token>`

---

## Flutter Screens

### Authentication Screens

#### Login Screen
- Email and password fields
- "Continue with Google" button
- Navigate to Register screen

#### Register Screen
- Full name, email, password, optional phone
- "Continue with Google" button
- Navigate to Login screen

### Main App Screens

#### Dashboard
- User profile card with avatar, name, email, member code
- My Assignments list with para number and status
- Quick actions: View Khanis, Select Para, Live Dua
- Logout button

#### Khani List
- Lists all Khanis with cards (scheduled, live, ended)
- Pull-to-refresh
- Floating action button to create new Khani
- Each card shows: title, date, time, location, prayer timing, duration in minutes, join code, status badge
- Host actions: Start Khani, End Khani, Start Live Dua

#### Create Khani Dialog
- Form fields: title, start date, start time, location
- Prayer after dropdown (Fajar/Zohar/Asar/Magrib/Isha)
- Duration in minutes (1-720)
- Optional description

#### Khani Details
- Full Khani information card
- Timer info (remaining minutes when live, duration when scheduled)
- Join code display with copy button
- Para grid (1-30) with status colors:
  - Green = Completed
  - Orange = Assigned to current user (tappable to complete)
  - Gray = Taken by another member (readonly)
  - White = Available for assignment
- Essalay Sawab text input and save button
- Start Khani button (if scheduled and user is host/creator)
- End Khani button (host only, when live)
- Live Dua button (host only, when live)

#### Para Selection
- Shows active Khani info with join code
- 30-para grid with same visual states as details
- Member code display
- Assign para by tapping available button
- Complete para via confirmation dialog

#### Live Dua Home
- Start Live Dua (Host) button
- Join with Khani Code button
- Brief description of the unified join code flow

#### Start Live Dua
- Shows the Khani join code
- Choose stream type: Audio or Video
- Creates live dua session linked to the Khani

#### Join Live Dua
- Enter 8-character join code (same as Khani code)
- Joins Khani and navigates to details/session

#### Live Dua Session
- Session status card (Waiting / Live / Ended)
- Join code display with copy button
- Khani title and host name
- Host controls: Start Stream, End Session
- Client actions: Listen (audio), Watch (video), Share code
- Stream URL input dialog for host

#### Notifications
- List of all notifications with read/unread status
- Unread count badge
- Mark as read functionality
- Notification types: khani_started, khani_ended, stream_started, stream_ended

---

## Authentication & Security

### JWT Flow

1. User registers or logs in
2. Backend validates credentials and signs a JWT with `userId`
3. JWT is returned to the client and stored in `SharedPreferences`
4. All subsequent API requests include `Authorization: Bearer <token>`
5. Backend middleware verifies JWT and attaches user to `req.user`
6. Token expires in 7 days

### Password Security

- Passwords are hashed using **bcrypt** with cost factor 12
- Password hash field is excluded from query results by default (`select: false`)
- Never returned in API responses

### Member Code Generation

- 8-character alphanumeric code (uppercase letters + digits)
- Generated on registration
- Guaranteed unique via collision check loop
- Used for identification in community settings

### Google OAuth Flow

1. Client obtains ID token from Google Sign-In SDK
2. Token sent to backend `/api/auth/oauth/google`
3. Backend verifies token with Google's tokeninfo endpoint
4. If valid and email not registered, creates new user with `auth_provider: "google"`
5. If Google ID exists, returns existing user
6. JWT issued same as local login

---

## Live Dua Streaming Flow

The Quran Khani join code doubles as the live dua session identifier. There is no separate "live dua" creation step — the host starts the Khani, gets a join code, and that same code is used for the live dua stream.

```
Host Flow:
1. Host creates a new Quran Khani from the app
2. Host taps "Start Khani" → status changes to "live"
3. Backend generates an 8-char join code and sets host_id
4. Host shares the join code with participants
5. Host taps "Live Dua" from Khani details
6. Host selects stream type (audio/video)
7. Host enters RTMP/WebRTC stream URL
8. Host taps "Start Stream" → live dua status changes to "live"
9. Participants can now listen/watch
10. Host taps "End Khani" when dua is complete
11. All joined members receive push notification

Client Flow:
1. Client taps "Join with Khani Code" from Live Dua home
2. Enters the 8-char join code shared by host
3. Backend validates code and adds client as participant
4. Client sees Khani details with live dua status
5. When host starts stream, status changes to "live"
6. Client taps "Listen" (audio) or "Watch" (video)
7. When host ends Khani, client receives push notification
```

### Stream URL Format

The `stream_url` field accepts standard streaming URLs:
- **RTMP**: `rtmp://stream.server.com/live/stream-key`
- **WebRTC**: `https://webrtc.server.com/session/abc123`
- **HLS**: `https://cdn.server.com/live/stream.m3u8`

The app currently shows the URL in the UI. Actual playback/streaming requires integration with a media player or WebRTC client library (e.g., `video_player`, `flutter_webrtc`).

---

## Push Notifications

When the host ends a Quran Khani, the backend creates notifications for all participants (excluding the host). The Flutter app can fetch these via the notifications API.

### Notification Types
- `khani_started` — Host has started the Khani session
- `khani_ended` — Host has ended the Khani session
- `stream_started` — Live dua stream has started
- `stream_ended` — Live dua stream has ended

### In-App Notification Center
- Accessible from Dashboard via notifications icon
- Shows unread count badge
- Pull to refresh
- Mark individual notifications as read
- Relative timestamps (Just now, 5 min ago, etc.)

---

## Troubleshooting

### Backend Issues

**MongoDB Connection Failed**
- Ensure MongoDB is running: `mongod --dbpath /path/to/data`
- Check `MONGODB_URI` in `.env` is correct
- For Atlas, verify IP whitelist and credentials

**JWT Token Invalid**
- Ensure `JWT_SECRET` is set in `.env`
- Tokens expire after 7 days — user must re-login

**Google OAuth Not Working**
- Verify `GOOGLE_CLIENT_ID` is set
- Ensure Google Client ID matches your OAuth app configuration
- Check that authorized origins/redirect URIs include your backend URL

### Flutter Issues

**Google Sign-In Not Working**
- Add `GoogleService-Info.plist` (iOS) and `google-services.json` (Android)
- Ensure SHA-1/SHA-256 fingerprints are added in Google Cloud Console
- Run `flutter clean` and rebuild

**API Calls Failing**
- Verify `apiBaseUrl` in `lib/config/app_config.dart` points to running backend
- Check device/emulator can reach backend IP (use `10.0.2.2` for Android emulator)
- Ensure CORS is enabled on backend (already configured)

**Para Grid Not Updating**
- Ensure backend is running and MongoDB has data
- Check network connectivity
- Verify user is authenticated (token present)

---
