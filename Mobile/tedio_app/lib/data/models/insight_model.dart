class InsightModel {
  final String id;
  final String userId;
  final String name;
  final String severity;
  final String message;
  final double scorePct;
  final List<int> spark;
  final double matchScore;
  final DateTime createdAt;
  final InsightIntervention? intervention;
  final double? averageRating;
  final int? totalRatings;

  InsightModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.severity,
    required this.message,
    required this.scorePct,
    required this.spark,
    required this.matchScore,
    required this.createdAt,
    this.intervention,
    this.averageRating,
    this.totalRatings,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    // Handle spark which can contain ints or doubles
    List<int> sparkData = [];
    if (json['spark'] != null && json['spark'] is List) {
      sparkData = (json['spark'] as List).map((e) {
        if (e is int) return e;
        if (e is double) return e.round();
        if (e is String) return int.tryParse(e) ?? 0;
        return 0;
      }).toList();
    }
    
    // Handle matchScore which can be int, double, or string
    double matchScoreValue = 0.0;
    if (json['matchScore'] != null) {
      if (json['matchScore'] is int) {
        matchScoreValue = json['matchScore'].toDouble();
      } else if (json['matchScore'] is double) {
        matchScoreValue = json['matchScore'];
      } else if (json['matchScore'] is String) {
        matchScoreValue = double.tryParse(json['matchScore']) ?? 0.0;
      }
    }
    
    // Handle globalRating if present
    double? avgRating;
    int? totalRatings;
    if (json['globalRating'] != null && json['globalRating'] is Map) {
      final globalRating = json['globalRating'];
      if (globalRating['average'] != null) {
        if (globalRating['average'] is int) {
          avgRating = globalRating['average'].toDouble();
        } else if (globalRating['average'] is double) {
          avgRating = globalRating['average'];
        }
      }
      if (globalRating['totalRaters'] != null) {
        if (globalRating['totalRaters'] is int) {
          totalRatings = globalRating['totalRaters'];
        } else if (globalRating['totalRaters'] is String) {
          totalRatings = int.tryParse(globalRating['totalRaters']);
        }
      }
    }
    
    return InsightModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      severity: json['severity'] ?? 'low',
      message: json['message'] ?? '',
      scorePct: (json['score_pct'] ?? 0).toDouble(),
      spark: sparkData,
      matchScore: matchScoreValue,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      intervention: json['intervention'] != null 
          ? InsightIntervention.fromJson(json['intervention'])
          : null,
      averageRating: avgRating,
      totalRatings: totalRatings,
    );
  }

  String get severityLabel {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'High';
      case 'moderate':
        return 'Moderate';
      case 'low':
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  String get severityEmoji {
    switch (severity.toLowerCase()) {
      case 'high':
        return '🔴';
      case 'moderate':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }
}

class InsightIntervention {
  final String whyItMatters;
  final List<String> whatYouCanDo;
  final String developmentalContext;
  final Map<String, dynamic>? primaryTip;
  final List<Map<String, dynamic>>? moreTips;

  InsightIntervention({
    required this.whyItMatters,
    required this.whatYouCanDo,
    required this.developmentalContext,
    this.primaryTip,
    this.moreTips,
  });

  factory InsightIntervention.fromJson(Map<String, dynamic> json) {
    // Handle whatYouCanDo which might come as moreTips from backend
    List<String> tips = [];
    if (json['whatYouCanDo'] != null && json['whatYouCanDo'] is List) {
      tips = List<String>.from(json['whatYouCanDo']);
    } else if (json['moreTips'] != null && json['moreTips'] is List) {
      // Extract descriptions from moreTips if whatYouCanDo is not present
      tips = (json['moreTips'] as List).map((tip) {
        if (tip is Map && tip['description'] != null) {
          return tip['description'].toString();
        }
        return '';
      }).where((s) => s.isNotEmpty).toList();
    }
    
    return InsightIntervention(
      whyItMatters: json['whyItMatters'] ?? '',
      whatYouCanDo: tips,
      developmentalContext: json['developmentalContext'] ?? '',
      primaryTip: json['primaryTip'] is Map ? Map<String, dynamic>.from(json['primaryTip']) : null,
      moreTips: json['moreTips'] is List 
        ? (json['moreTips'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : null,
    );
  }
}