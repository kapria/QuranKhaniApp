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
  final int durationDays;
  final String? description;
  final bool isActive;
  final String createdBy;
  final String? creatorName;
  final DateTime createdAt;
  final DateTime? endedAt;

  Khani({
    required this.id,
    required this.title,
    required this.startDate,
    required this.startTime,
    this.location,
    required this.prayerAfter,
    required this.durationDays,
    this.description,
    required this.isActive,
    required this.createdBy,
    this.creatorName,
    required this.createdAt,
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
      durationDays: json['duration_days'] ?? 30,
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'] ?? '',
      creatorName: json['profiles']?['name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
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
      'duration_days': durationDays,
      'description': description,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
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
  final String hostId;
  final String uniqueCode;
  final String status;
  final String? streamType;
  final String? streamUrl;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<Participant> participants;
  final String? khaniTitle;
  final String? hostName;
  final DateTime createdAt;

  LiveDuaSession({
    required this.id,
    required this.khaniId,
    required this.hostId,
    required this.uniqueCode,
    required this.status,
    this.streamType,
    this.streamUrl,
    this.startedAt,
    this.endedAt,
    required this.participants,
    this.khaniTitle,
    this.hostName,
    required this.createdAt,
  });

  factory LiveDuaSession.fromJson(Map<String, dynamic> json) {
    final participantsList = (json['participants'] as List? ?? []);
    return LiveDuaSession(
      id: json['id'] ?? '',
      khaniId: json['khani_id'] ?? '',
      hostId: json['host_id'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      status: json['status'] ?? 'waiting',
      streamType: json['stream_type'],
      streamUrl: json['stream_url'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      participants: participantsList.map((p) => Participant.fromJson(p)).toList(),
      khaniTitle: json['khani_id']?['title'] ?? json['khani']?['title'],
      hostName: json['host_id']?['name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khani_id': khaniId,
      'host_id': hostId,
      'unique_code': uniqueCode,
      'status': status,
      'stream_type': streamType,
      'stream_url': streamUrl,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Participant {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? userName;
  final String? memberCode;
  final String? avatarUrl;

  Participant({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
    this.memberCode,
    this.avatarUrl,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
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
