import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class RemoveDevicesScreen extends StatefulWidget {
  const RemoveDevicesScreen({super.key});

  @override
  State<RemoveDevicesScreen> createState() => _RemoveDevicesScreenState();
}

class _RemoveDevicesScreenState extends State<RemoveDevicesScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'remove-devices';

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
      title: 'Remove Devices from Bedroom',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      resources: const [
        ResourceItem(
          title: 'Help Kids Balance Phones and Screens with Sleep',
          url: 'https://www.commonsensemedia.org/articles/how-to-help-kids-balance-phones-and-screens-with-sleep',
        ),
        ResourceItem(
          title: 'How to Raise a Reader',
          url: 'https://www.commonsensemedia.org/articles/how-to-raise-a-reader',
        ),
        ResourceItem(
          title: 'The Power of Bedtime: Best Stories and Activities',
          url: 'https://www.babysensemonitors.com/blogs/news/the-power-of-bedtime-best-stories-and-activities-for-kids',
        ),
      ],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Pick a new charging spot — choose a neutral, shared space like the kitchen counter or living room shelf'),
              _buildStep('2', 'Communicate the change clearly and kindly:'),
              Container(
                margin: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  '"Phones sleep in the kitchen so our brains can rest, too."',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              _buildStep('3', 'Create a bedtime basket for devices if needed. Label it "tech bedtime" to normalize the habit'),
              _buildStep('4', 'Set a consistent hand-off time, like "8:30 p.m. is tech tuck-in."'),
              _buildStep('5', 'Lead by example — parents\' devices go in the basket too!'),
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
                      'Time to complete: ~10 minutes',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Soothing Activity Pairing',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'When turning the device off (especially before bed), immediately follow with a calm offline routine so the transition feels comforting, not abrupt.',
                style: TextStyle(height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Examples:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.book,
                'Parent-read bedtime story (no screens — so the last input before sleep is your voice and imagination, not a video)',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.music_note,
                'Quiet music or lullabies (low volume, slow tempo)',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.palette,
                'Gentle drawing or coloring (soft lighting, minimal conversation)',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.extension,
                'Simple puzzle or tactile toy (fidgets, soft blocks)',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.self_improvement,
                'Guided relaxation (deep breaths together or short mindfulness exercise)',
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
                'Removing devices from bedrooms creates better sleep environments and establishes healthy boundaries. Here\'s why it\'s beneficial:',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildTip(
                Icons.bedtime,
                'Signals a consistent "wind-down" cue to the brain',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.block,
                'Prevents stimulating content from being the final experience before sleep',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.family_restroom,
                'Strengthens positive parent–child connection during the transition',
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
                        'Sleep is crucial for children\'s development including mental and physical health. Screen-free bedrooms support better rest.',
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
          title: 'Tips for Success',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.family_restroom,
                'Kids mirror adult behavior — if your phone stays in the bedroom, it\'s harder to justify the rule',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.child_care,
                'Let your child pick a wind-down replacement: a book, nightlight, music, or podcast',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.cable,
                'Use charging cables with limited range to discourage sneaky overnight use',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.schedule,
                'If resistance is high, transition slowly: start with just weekends or one night per week',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.alarm,
                'Consider using a traditional alarm clock instead of phones for wake-up',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Alternative Bedtime Routine Ideas',
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a cozy, screen-free bedtime routine:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTip(
                  Icons.auto_stories,
                  'Read together for 15-20 minutes',
                ),
                const SizedBox(height: 8),
                _buildTip(
                  Icons.chat,
                  'Share highlights from the day',
                ),
                const SizedBox(height: 8),
                _buildTip(
                  Icons.bedtime,
                  'Practice gratitude or positive affirmations',
                ),
                const SizedBox(height: 8),
                _buildTip(
                  Icons.nights_stay,
                  'Listen to calming nature sounds or soft instrumental music',
                ),
              ],
            ),
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