import 'package:flutter/material.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class HikeDetailViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  late Hike _hike;
  List<Observation> _observations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Hike get hike => _hike;
  List<Observation> get observations => _observations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Set hike when VM created
  void setHike(Hike hike) {
    _hike = hike;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Load all observations for single hike
  Future<void> loadObservations() async {
    try {
      _setLoading(true);
      _observations = await _databaseService.getAllObservationsForHike(
        _hike.id!,
      );
    } catch (e) {
      _setError("Failed to load observations: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Add new observation
  Future<void> addObservation(String obsText, String? comments) async {
    try {
      final String currentTime = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.now());
      Observation newObs = Observation(
        observation: obsText,
        observationTime: currentTime,
        comments: comments,
        hikeId: _hike.id!,
      );
      await _databaseService.insertObservation(newObs);
      await loadObservations();
    } catch (e) {
      _setError("Failed to add observation: $e");
    }
  }

  // Delete observation
  Future<void> deleteObservation(int observationId) async {
    try {
      await _databaseService.deleteObservation(observationId);
      await loadObservations(); // Refresh the list
    } catch (e) {
      _setError("Failed to delete observation: $e");
    }
  }
}
