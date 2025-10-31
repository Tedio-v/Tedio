import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class TimeTogetherScreen extends StatefulWidget {
  const TimeTogetherScreen({super.key});

  @override
  State<TimeTogetherScreen> createState() => _TimeTogetherScreenState();
}

class _TimeTogetherScreenState extends State<TimeTogetherScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'time-together';

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
      title: 'Suggest Time Together',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      resources: const [
        ResourceItem(
          title: 'Family Media Planning',
          url: 'https://www.commonsensemedia.org/articles/family-media-planning',
        ),
        ResourceItem(
          title: 'Screen-Free Family Activities',
          url: 'https://www.commonsensemedia.org/articles/screen-free-family-activities',
        ),
      ],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'When someone reaches for a device, suggest an activity together'),
              _buildStep('2', 'Keep suggestions simple and age-appropriate'),
              _buildStep('3', 'Be ready to join in immediately'),
              _buildStep('4', 'Make it fun, not a chore'),
              _buildStep('5', 'Rotate who gets to choose the activity'),
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
                      'Time to complete: Varies by activity',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Why it helps',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Offering engaging alternatives to screens strengthens family bonds and shows that real-world activities can be just as entertaining. It creates positive associations with screen-free time.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Building these positive family connections creates lasting memories and shows children that fulfillment comes from relationships, not just screens.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Quick Activity Ideas (5-15 minutes)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.casino,
                'Card games or board games',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.music_note,
                'Dance party to favorite songs',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.directions_walk,
                'Quick walk around the block',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.palette,
                'Drawing or coloring together',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Longer Activities (30+ minutes)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.kitchen,
                'Cook or bake something together',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.build,
                'Build with blocks or LEGO',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.nature,
                'Nature scavenger hunt',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.book,
                'Read a book aloud',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.extension,
                'Work on a puzzle',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Tips for Success',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.schedule,
                'Start small - even 5 minutes of together time can redirect from screens.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.favorite,
                'Show genuine enthusiasm for the activity to make it appealing.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.child_care,
                'Let children choose activities sometimes to give them ownership.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.repeat,
                'Make it a routine - suggest activities at the same times daily.',
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