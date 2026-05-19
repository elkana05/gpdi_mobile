import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final _service = AdminService();

  List<LetterRequestModel> _letters = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<LetterRequestModel> get letters => _letters;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchLetters() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _letters = await _service.getLetters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitLetterRequest(String type, String note) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _service.requestLetter({
        'jenis_surat': type,
        'keterangan': note,
      });
      await fetchLetters(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _notifications = await _service.getNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
