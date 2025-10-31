class ApiConstants {
  static const String baseUrl = 'http://178.128.74.9:5001';
  static const String apiPrefix = '/api';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static const String authEndpoint = '$apiPrefix/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String completeOnboardingEndpoint = '$authEndpoint/complete-onboarding';
  
  static const String youtubeHistoryEndpoint = '$apiPrefix/youtube-history';
  static const String youtubeHistoryStatusEndpoint = '$youtubeHistoryEndpoint/status';
  
  static const String insightsEndpoint = '$apiPrefix/insights';
  static const String generateInsightsEndpoint = '$insightsEndpoint/generate';
  static const String globalRatingsEndpoint = '$insightsEndpoint/global-ratings';
  
  static const String settingsEndpoint = '$apiPrefix/settings';
  static const String quickActionsEndpoint = '$apiPrefix/quick-actions/complete';
}