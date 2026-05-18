import 'package:flutter/material.dart';
import '../models/church_profile_model.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';

class ContentProvider extends ChangeNotifier {
  final _service = ContentService();

  ChurchProfileModel? _profile;
  List<GalleryModel> _gallery = [];
  List<DevotionalModel> _devotionals = [];
  List<AnnouncementModel> _announcements = [];
  List<Map<String, dynamic>> _pastors = [];

  bool _isLoading = false;
  String _errorMessage = '';

  ChurchProfileModel? get profile => _profile;
  List<GalleryModel> get gallery => _gallery;
  List<DevotionalModel> get devotionals => _devotionals;
  List<AnnouncementModel> get announcements => _announcements;
  List<Map<String, dynamic>> get pastors => _pastors;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchChurchProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _profile = await _service.getChurchProfile();
      // Fetch pastors as well to match React logic
      _pastors = await _service.getPastors();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGallery() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _gallery = await _service.getGallery();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDevotionals() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _devotionals = await _service.getDevotionals();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _announcements = await _service.getAnnouncements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
