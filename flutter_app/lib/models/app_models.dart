class User {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String memberCode;
  final String? googleId;
  final String? avatarUrl;
  final String authProvider;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.memberCode,
    this.googleId,
    this.avatarUrl,
    this.authProvider = 'local',
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      memberCode: json['member_code'] ?? '',
      googleId: json['google_id'],
      avatarUrl: json['avatar_url'],
      authProvider: json['auth_provider'] ?? 'local',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'member_code': memberCode,
      'google_id': googleId,
      'avatar_url': avatarUrl,
      'auth_provider': authProvider,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Khani {
  final String id;
  final String title;
  final String startDate;
  final String startTime;
  final String? location;
  final String prayerAfter;
  final int durationMinutes;
  final String? description;
  final String status;
  final String joinCode;
  final String createdBy;
  final String? creatorName;
  final String? hostId;
  final String? hostName;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  Khani({
    required this.id,
    required this.title,
    required this.startDate,
    required this.startTime,
    this.location,
    required this.prayerAfter,
    required this.durationMinutes,
    this.description,
    required this.status,
    required this.joinCode,
    required this.createdBy,
    this.creatorName,
    this.hostId,
    this.hostName,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  factory Khani.fromJson(Map<String, dynamic> json) {
    return Khani(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      startDate: json['start_date'] ?? '',
      startTime: json['start_time'] ?? '',
      location: json['location'],
      prayerAfter: json['prayer_after'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 60,
      description: json['description'],
      status: json['status'] ?? 'scheduled',
      joinCode: json['join_code'] ?? '',
      createdBy: json['created_by'] ?? '',
      creatorName: json['profiles']?['name'],
      hostId: json['host_id'] ?? json['host_id']?['_id'],
      hostName: json['host_profile']?['name'] ?? json['host_id']?['name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate,
      'start_time': startTime,
      'location': location,
      'prayer_after': prayerAfter,
      'duration_minutes': durationMinutes,
      'description': description,
      'status': status,
      'join_code': joinCode,
      'created_by': createdBy,
      'host_id': hostId,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }
}

class ParaAssignment {
  final String id;
  final String khaniId;
  final int paraNumber;
  final String userId;
  final String? userName;
  final String? memberCode;
  final String status;
  final DateTime? completedAt;
  final DateTime createdAt;

  ParaAssignment({
    required this.id,
    required this.khaniId,
    required this.paraNumber,
    required this.userId,
    this.userName,
    this.memberCode,
    required this.status,
    this.completedAt,
    required this.createdAt,
  });

  factory ParaAssignment.fromJson(Map<String, dynamic> json) {
    return ParaAssignment(
      id: json['id'] ?? '',
      khaniId: json['khani_id'] ?? '',
      paraNumber: json['para_number'] ?? 0,
      userId: json['user_id'] ?? '',
      userName: json['profiles']?['name'],
      memberCode: json['profiles']?['member_code'],
      status: json['status'] ?? 'assigned',
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khani_id': khaniId,
      'para_number': paraNumber,
      'user_id': userId,
      'status': status,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SawabDetails {
  final String id;
  final String khaniId;
  final String details;
  final DateTime createdAt;
  final DateTime updatedAt;

  SawabDetails({
    required this.id,
    required this.khaniId,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SawabDetails.fromJson(Map<String, dynamic> json) {
    return SawabDetails(
      id: json['id'] ?? '',
      khaniId: json['khani_id'] ?? '',
      details: json['details'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khani_id': khaniId,
      'details': details,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LiveDuaSession {
  final String id;
  final String khaniId;
  final String? streamType;
  final String? streamUrl;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? khaniTitle;
  final String? joinCode;
  final DateTime createdAt;

  LiveDuaSession({
    required this.id,
    required this.khaniId,
    this.streamType,
    this.streamUrl,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.khaniTitle,
    this.joinCode,
    required this.createdAt,
  });

  factory LiveDuaSession.fromJson(Map<String, dynamic> json) {
    return LiveDuaSession(
      id: json['id'] ?? '',
      khaniId: json['khani_id'] ?? '',
      streamType: json['stream_type'],
      streamUrl: json['stream_url'],
      status: json['status'] ?? 'waiting',
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      khaniTitle: json['khani_id']?['title'] ?? json['khani']?['title'],
      joinCode: json['khani_id']?['join_code'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khani_id': khaniId,
      'stream_type': streamType,
      'stream_url': streamUrl,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class KhaniParticipant {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? userName;
  final String? memberCode;
  final String? avatarUrl;

  KhaniParticipant({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
    this.memberCode,
    this.avatarUrl,
  });

  factory KhaniParticipant.fromJson(Map<String, dynamic> json) {
    return KhaniParticipant(
      userId: json['user_id'] ?? '',
      role: json['role'] ?? 'listener',
      joinedAt: DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
      userName: json['user_id']?['name'],
      memberCode: json['user_id']?['member_code'],
      avatarUrl: json['user_id']?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String khaniId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.khaniId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      khaniId: json['khani_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'khani_id': khaniId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
