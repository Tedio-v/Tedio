import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class PhysicalTimerScreen extends StatefulWidget {
  const PhysicalTimerScreen({super.key});

  @override
  State<PhysicalTimerScreen> createState() => _PhysicalTimerScreenState();
}

class _PhysicalTimerScreenState extends State<PhysicalTimerScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'physical-timer';

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
      title: 'Set a Physical Timer',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      tutorialUrl: 'https://www.youtube.com/watch?v=example',
      tutorialTitle: 'How to use a kitchen timer effectively',
      resources: const [
        ResourceItem(
          title: 'Benefits of Physical Timers for Kids',
          url: 'https://www.commonsensemedia.org/articles/screen-time-limits',
        ),
      ],
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Get a physical kitchen timer (not a phone timer!)'),
              _buildStep('2', 'Set it for 20 minutes when screen time starts'),
              _buildStep('3', 'Place the timer where your child can see it'),
              _buildStep('4', 'When it rings, take a 5-minute break'),
              _buildStep('5', 'Repeat the cycle as needed'),
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
                      'Time to complete: 2 minutes to set up',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Why Physical Timers Work Better',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBenefit(
                Icons.visibility,
                'Visual Countdown',
                'Kids can see time passing, making it tangible',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.phone_disabled,
                'No Phone Distraction',
                'Avoids the temptation of checking notifications',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.alarm,
                'Clear Boundaries',
                'The loud ring creates a definitive stopping point',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.psychology,
                'Builds Self-Control',
                'Teaches time management without constant reminders',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Recommended Timer Schedule',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScheduleItem('Ages 3-6', '10-15 minute sessions'),
              _buildScheduleItem('Ages 7-10', '20 minute sessions'),
              _buildScheduleItem('Ages 11+', '25-30 minute sessions'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Always follow with a 5-minute break away from screens',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Break Time Ideas',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreakIdea(Icons.directions_walk, 'Quick walk around the house'),
              _buildBreakIdea(Icons.water_drop, 'Get a drink of water'),
              _buildBreakIdea(Icons.pets, 'Play with a pet'),
              _buildBreakIdea(Icons.visibility, 'Look out the window at distant objects'),
              _buildBreakIdea(Icons.fitness_center, 'Do 10 jumping jacks'),
              _buildBreakIdea(Icons.chat_bubble, 'Have a quick chat with family'),
            ],
          ),
        ),
        ContentCard(
          title: 'Pro Tips',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.shopping_cart,
                'Let your child pick out their own timer - ownership increases buy-in',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.celebration,
                'Celebrate when they respond to the timer without reminders',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.trending_up,
                'Gradually increase session length as they get better at managing time',
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

  Widget _buildScheduleItem(String age, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 100,
            child: Text(
              age,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(
            duration,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakIdea(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
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