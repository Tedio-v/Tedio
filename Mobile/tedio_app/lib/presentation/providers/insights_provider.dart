import 'package:flutter/material.dart';
import '../../data/models/insight_model.dart';
import '../../data/services/insights_service.dart';

class InsightsProvider extends ChangeNotifier {
  final InsightsService _insightsService = InsightsService();
  
  List<InsightModel> _insights = [];
  bool _isLoading = false;
  String? _error;

  List<InsightModel> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInsights(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _insights = await _insightsService.getInsights(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateInsights(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _insightsService.generateInsights(token);
      await loadInsights(token);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rateInsight(String token, String insightId, int rating) async {
    try {
      await _insightsService.rateInsight(token, insightId, rating);
      await loadInsights(token);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  InsightModel? getInsightById(String id) {
    try {
      return _insights.firstWhere((insight) => insight.id == id);
    } catch (e) {
      return null;
    }
  }

  List<InsightModel> get highSeverityInsights {
    return _insights.where((i) => i.severity.toLowerCase() == 'high').toList();
  }

  List<InsightModel> get moderateSeverityInsights {
    return _insights.where((i) => i.severity.toLowerCase() == 'moderate').toList();
  }

  List<InsightModel> get lowSeverityInsights {
    return _insights.where((i) => i.severity.toLowerCase() == 'low').toList();
  }
}