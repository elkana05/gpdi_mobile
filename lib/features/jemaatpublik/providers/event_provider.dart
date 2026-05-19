import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final _service = EventService();

  List<WorshipScheduleModel> _worshipSchedules = [];
  List<ActivityModel> _activities = [];
  List<RayonScheduleModel> _rayonSchedules = [];

  bool _isLoading = false;
  String _errorMessage = '';

  List<WorshipScheduleModel> get worshipSchedules => _worshipSchedules;
  List<ActivityModel> get activities => _activities;
  List<RayonScheduleModel> get rayonSchedules => _rayonSchedules;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchPublicEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getPublicWorship(),
        _service.getPublicActivities(),
      ]);
      _worshipSchedules = results[0] as List<WorshipScheduleModel>;
      _activities = results[1] as List<ActivityModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRayonSchedules() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _rayonSchedules = await _service.getJemaatRayonSchedules();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
