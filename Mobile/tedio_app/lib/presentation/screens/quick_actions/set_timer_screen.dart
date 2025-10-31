import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class SetTimerScreen extends StatefulWidget {
  const SetTimerScreen({super.key});

  @override
  State<SetTimerScreen> createState() => _SetTimerScreenState();
}

class _SetTimerScreenState extends State<SetTimerScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'set-timer';

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;
      if (token != null) {
        final completedActions = await _quickActionService.getCompletedActions(token);
        if (mounted) {
          setState(() {
            _isCompleted = completedActions.contains(actionId);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleCompletion(bool? value) async {
    if (value == null) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;
      if (token != null) {
        if (value) {
          await _quickActionService.completeQuickAction(token, actionId);
        } else {
          await _quickActionService.uncompleteQuickAction(token, actionId);
        }
        setState(() {
          _isCompleted = value;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return QuickActionBase(
      title: 'Use a 20-Minute Kitchen Timer',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      resources: const [],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Find a physical kitchen timer (not your phone!)'),
              _buildStep('2', 'Set it for 20 minutes when starting YouTube'),
              _buildStep('3', 'Place it visible to your child'),
              _buildStep('4', 'When it rings, YouTube time is done'),
              _buildStep('5', 'Be consistent - use it every time'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.timer, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Time to complete: 1 minute',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Why 20 Minutes?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReason(
                Icons.science,
                'Research shows 20 minutes is optimal for focused attention in children',
              ),
              const SizedBox(height: 8),
              _buildReason(
                Icons.psychology,
                'Short enough to maintain quality content choices',
              ),
              const SizedBox(height: 8),
              _buildReason(
                Icons.trending_down,
                'Prevents algorithm from serving increasingly random content',
              ),
              const SizedBox(height: 8),
              _buildReason(
                Icons.family_restroom,
                'Creates natural transition points for other activities',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Making It Stick',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.celebration,
                'Celebrate when they turn off YouTube without reminders',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.calendar_today,
                'Use it consistently - same rule every day',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.people,
                'Involve your child in setting the timer',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.local_activity,
                'Have a fun activity ready for when timer goes off',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Timer Alternatives',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlternative(
                'Visual Timer',
                'Shows time passing with color (great for younger kids)',
              ),
              const SizedBox(height: 8),
              _buildAlternative(
                'Sand Timer',
                'Physical representation of time flowing',
              ),
              const SizedBox(height: 8),
              _buildAlternative(
                'Egg Timer',
                'Classic kitchen timer with loud ring',
              ),
              const SizedBox(height: 8),
              _buildAlternative(
                'Time Timer',
                'Red disk shows time remaining visually',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReason(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternative(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}