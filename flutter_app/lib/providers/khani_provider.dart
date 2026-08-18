import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

class KhaniProvider extends ChangeNotifier {
  List<Khani> _khanis = [];
  List<ParaAssignment> _assignments = [];
  List<ParaAssignment> _khaniAssignments = [];
  Khani? _selectedKhani;
  SawabDetails? _sawabDetails;
  LiveDuaSession? _liveSession;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Khani> get khanis => _khanis;
  List<ParaAssignment> get assignments => _assignments;
  List<ParaAssignment> get khaniAssignments => _khaniAssignments;
  Khani? get selectedKhani => _selectedKhani;
  SawabDetails? get sawabDetails => _sawabDetails;
  LiveDuaSession? get liveSession => _liveSession;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchKhanis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get('/khanis');
      if (response['status'] == 'success') {
        _khanis = (response['data']['khanis'] as List)
            .map((json) => Khani.fromJson(json))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createKhani(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post('/khanis', data);
      if (response['status'] == 'success') {
        final newKhani = Khani.fromJson(response['data']['khani']);
        _khanis.insert(0, newKhani);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchKhaniDetails(String khaniId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get('/khanis/$khaniId');
      if (response['status'] == 'success') {
        _selectedKhani = Khani.fromJson(response['data']['khani']);
        _khaniAssignments = (response['data']['assignments'] as List)
            .map((json) => ParaAssignment.fromJson(json))
            .toList();
        if (response['data']['sawabDetails'] != null) {
          _sawabDetails = SawabDetails.fromJson(response['data']['sawabDetails']);
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startKhani(String khaniId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final khani = await ApiService().startKhani(khaniId);
      if (khani != null) {
        final index = _khanis.indexWhere((k) => k.id == khaniId);
        if (index != -1) {
          _khanis[index] = khani;
        }
        if (_selectedKhani?.id == khaniId) {
          _selectedKhani = khani;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Khani?> joinKhani(String joinCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final khani = await ApiService().joinKhani(joinCode);
      _isLoading = false;
      notifyListeners();
      return khani;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> endKhani(String khaniId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post('/khanis/$khaniId/end', {});
      if (response['status'] == 'success') {
        final index = _khanis.indexWhere((k) => k.id == khaniId);
        if (index != -1) {
          _khanis[index] = Khani.fromJson(response['data']['khani']);
        }
        if (_selectedKhani?.id == khaniId) {
          _selectedKhani = Khani.fromJson(response['data']['khani']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignPara(String khaniId, int paraNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post('/paras/assign', {
        'khani_id': khaniId,
        'para_number': paraNumber,
      });

      if (response['status'] == 'success') {
        final assignment = ParaAssignment.fromJson(response['data']['assignment']);
        _khaniAssignments.add(assignment);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePara(String assignmentId) async {
    try {
      final response = await ApiService().patch('/paras/$assignmentId/complete', {});
      if (response['status'] == 'success') {
        final index = _khaniAssignments.indexWhere((a) => a.id == assignmentId);
        if (index != -1) {
          _khaniAssignments[index] = ParaAssignment.fromJson(response['data']['assignment']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyAssignments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get('/paras/my-assignments');
      if (response['status'] == 'success') {
        _assignments = (response['data']['assignments'] as List)
            .map((json) => ParaAssignment.fromJson(json))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSawabDetails(String khaniId, String details) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post('/sawab', {
        'khani_id': khaniId,
        'details': details,
      });

      if (response['status'] == 'success') {
        _sawabDetails = SawabDetails.fromJson(response['data']['sawabDetails']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<LiveDuaSession?> startLiveDua(String joinCode, String streamType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await ApiService().startLiveDua(joinCode, streamType);
      if (session != null) {
        _liveSession = session;
      }
      _isLoading = false;
      notifyListeners();
      return session;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> joinLiveDua(String joinCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService().joinLiveDua(joinCode);
      if (data != null) {
        _liveSession = LiveDuaSession.fromJson(data['liveSession'] ?? {});
        _selectedKhani = Khani.fromJson(data['khani']);
      }
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> getLiveSession(String joinCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await ApiService().getLiveSessionByCode(joinCode);
      _liveSession = session;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startStream(String joinCode, String? streamUrl, String streamType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await ApiService().startStream(joinCode, streamUrl, streamType);
      if (success) {
        await getLiveSession(joinCode);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> endLiveDua(String joinCode) async {
    try {
      final success = await ApiService().endLiveDua(joinCode);
      if (success) {
        _liveSession = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final notifications = await ApiService().getNotifications();
      _notifications = notifications;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      return await ApiService().getUnreadNotificationCount();
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final success = await ApiService().markNotificationAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            khaniId: _notifications[index].khaniId,
            type: _notifications[index].type,
            title: _notifications[index].title,
            message: _notifications[index].message,
            data: _notifications[index].data,
            read: true,
            createdAt: _notifications[index].createdAt,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
