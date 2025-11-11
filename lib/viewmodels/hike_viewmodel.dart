import 'package:flutter/material.dart';
import '../models/hike.dart';
import '../services/database_service.dart';

// Manages hike data and operations 
class HikeViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Hike> _hikes = []; 
  bool _isLoading = false;
  String? _errorMessage; 

  // Getters
  List<Hike> get hikes => List.unmodifiable(_hikes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Private Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load all hikes
  Future<void> loadHikes() async {
    try {
      _setLoading(true);
      _clearError(); 
      _hikes = await _databaseService.getAllHikes(); 
    } catch (error) {
      _setError('Failed to load hikes: $error'); 
    } finally {
      _setLoading(false); 
    }
  }

  Future<void> searchHikes(String query) async {
    try {
      _setLoading(true);
      _clearError();
      _hikes = await _databaseService.searchHikes(
        query,
      ); 
    } catch (error) {
      _setError('Failed to search hikes: $error');
    } finally {
      _setLoading(false);
    }
  }

  // Add new hike 
  Future<void> addHike(Hike hike) async {
    try {
      _setLoading(true);
      _clearError();
      await _databaseService.insertHike(hike); 
      await loadHikes(); 
    } catch (error) {
      _setError('Failed to add hike: $error'); 
    } finally {
      _setLoading(false); 
    }
  }

  // Update hike
  Future<void> updateHike(Hike hike) async {
    try {
      _setLoading(true); 
      _clearError();
      await _databaseService.updateHike(hike); 
      await loadHikes();
    } catch (error) {
      _setError('Failed to update hike: $error'); 
    } finally {
      _setLoading(false);
    }
  }

  // Delete hike
  Future<void> deleteHike(int hikeId) async {
    try {
      _setLoading(true); 
      _clearError();
      await _databaseService.deleteHike(hikeId);
      await loadHikes();
    } catch (error) {
      _setError('Failed to delete hike: $error'); 
    } finally {
      _setLoading(false);
    }
  }

  // Delete all hikes
  Future<void> deleteAllHikes() async {
    try {
      _setLoading(true);
      _clearError();
      await _databaseService.deleteAllData();
      await loadHikes();
    } catch (error) {
      _setError('Failed to delete all hikes: $error');
    } finally {
      _setLoading(false);
    }
  }
}
