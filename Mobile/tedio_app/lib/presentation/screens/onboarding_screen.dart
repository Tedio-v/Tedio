import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../../data/services/youtube_history_service.dart';
import '../../data/services/insights_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final YouTubeHistoryService _historyService = YouTubeHistoryService();
  final InsightsService _insightsService = InsightsService();
  
  bool _isUploading = false;
  bool _isGeneratingInsights = false;
  bool _uploadComplete = false;
  String? _error;

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
          _error = null;
        });

        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);
        
        List<Map<String, dynamic>> history = [];
        if (jsonData is List) {
          history = List<Map<String, dynamic>>.from(jsonData);
        } else {
          throw Exception('Invalid JSON format. Expected a list of video history.');
        }

        if (!mounted) return;
        
        final authProvider = context.read<AuthProvider>();
        if (authProvider.token == null) {
          throw Exception('Authentication required');
        }

        await _historyService.uploadHistory(authProvider.token!, history);
        
        setState(() {
          _uploadComplete = true;
          _isUploading = false;
        });

        _generateInsights();
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isUploading = false;
      });
    }
  }

  Future<void> _generateInsights() async {
    setState(() {
      _isGeneratingInsights = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.token == null) {
        throw Exception('Authentication required');
      }

      await _insightsService.generateInsights(authProvider.token!);
      await authProvider.completeOnboarding();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isGeneratingInsights = false;
      });
    }
  }

  void _skipForNow() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.completeOnboarding();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to Tedio',
          style: AppTypography.brand(fontSize: 30),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(
                      Icons.upload_file,
                      size: 80,
                      color: AppColors.link,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hi ${authProvider.currentUser?.childName ?? 'there'}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'To get personalized insights about your child\'s YouTube viewing patterns, we need their watch history.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to get your YouTube history:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildStep(context, '1', 'Go to takeout.google.com'),
                            _buildStep(context, '2', 'Select "YouTube and YouTube Music"'),
                            _buildStep(context, '3', 'Choose "history" only'),
                            _buildStep(context, '4', 'Download and extract the ZIP file'),
                            _buildStep(context, '5', 'Find "watch-history.json" in the folder'),
                            _buildStep(context, '6', 'Upload that file here'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.08),
                          border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.danger,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_uploadComplete && !_isGeneratingInsights) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentMint,
                          border: Border.all(color: AppColors.success.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Upload complete! Generating insights...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: (_isUploading || _isGeneratingInsights) ? null : _pickAndUploadFile,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload YouTube History'),
                ),
                const SizedBox(height: 12),
                if (_isGeneratingInsights) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Generating personalized insights...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextButton(
                  onPressed: (_isUploading || _isGeneratingInsights) ? null : _skipForNow,
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentSlate,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.link,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
