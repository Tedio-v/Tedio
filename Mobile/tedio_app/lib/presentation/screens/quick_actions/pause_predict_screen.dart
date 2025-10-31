import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class PausePredictScreen extends StatefulWidget {
  const PausePredictScreen({super.key});

  @override
  State<PausePredictScreen> createState() => _PausePredictScreenState();
}

class _PausePredictScreenState extends State<PausePredictScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'pause-predict';

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
      title: 'Pause & Predict "30-Second Rule"',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      resources: const [
        ResourceItem(
          title: 'Teaching Kids Self-Control',
          url: 'https://www.commonsensemedia.org/articles/teaching-kids-self-control',
        ),
      ],
      content: [
        ContentCard(
          title: 'What is the 30-Second Rule?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Before clicking on any new video, pause for 30 seconds and predict what will happen. This simple habit helps build mindful viewing.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.psychology, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This technique builds executive function and reduces impulsive clicking',
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'How to Practice It',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Find a video you want to watch'),
              _buildStep('2', 'STOP - don\'t click yet!'),
              _buildStep('3', 'Look at the thumbnail and title'),
              _buildStep('4', 'Predict: "What do I think will happen in this video?"'),
              _buildStep('5', 'Count to 30 slowly'),
              _buildStep('6', 'Decide: "Do I still want to watch this?"'),
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
                      'Practice time: 5-10 videos per session',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Prediction Questions to Ask',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestion('Content', 'What will this video be about?'),
              _buildQuestion('Feeling', 'How will I feel after watching this?'),
              _buildQuestion('Learning', 'Will I learn something new?'),
              _buildQuestion('Time', 'How long is this video?'),
              _buildQuestion('Next', 'What will I want to watch next?'),
              _buildQuestion('Value', 'Is this the best use of my screen time?'),
            ],
          ),
        ),
        ContentCard(
          title: 'Why This Works',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBenefit(
                Icons.pause_circle,
                'Breaks the Auto-Click Pattern',
                'Interrupts mindless scrolling and clicking',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.visibility,
                'Increases Awareness',
                'Makes children conscious of their choices',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.psychology,
                'Builds Critical Thinking',
                'Encourages analysis before consumption',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.slow_motion_video,
                'Slows Down Consumption',
                'Reduces rapid video switching',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Making It Fun',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.emoji_events,
                'Make it a game - see who can make the best predictions',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.star,
                'Give points for accurate predictions',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.people,
                'Practice together as a family activity',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.celebration,
                'Celebrate when they choose NOT to watch a video',
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

  Widget _buildQuestion(String category, String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
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