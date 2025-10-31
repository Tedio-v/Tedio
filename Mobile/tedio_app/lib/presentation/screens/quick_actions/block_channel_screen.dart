import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class BlockChannelScreen extends StatefulWidget {
  const BlockChannelScreen({super.key});

  @override
  State<BlockChannelScreen> createState() => _BlockChannelScreenState();
}

class _BlockChannelScreenState extends State<BlockChannelScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'block-channel';

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
      title: 'Block a Channel',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      tutorialUrl: 'https://www.youtube.com/watch?v=spCYR59Hbbo',
      tutorialTitle: 'How to block a YouTube channel',
      content: [
        ContentCard(
          title: 'How to do it',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Remove an entire channel:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubStep('a', 'From your HOME SCREEN dashboard, tap More (⋮) next to the video title you\'d like to remove'),
                    _buildSubStep('b', 'Select "Don\'t recommend channel"'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Remove a single video from recommendations:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubStep('a', 'Go to the recommended video you\'d like to remove'),
                    _buildSubStep('b', 'Tap the More (⋮) button next to the video title'),
                    _buildSubStep('c', 'Select "Not interested"'),
                    _buildSubStep('d', 'Tell us why — choose from options like "I\'ve already watched this" or "I don\'t like this video"'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Turn ON Approved Content Only (only for YouTube Kids):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubStep('a', 'Open YouTube Kids on your child\'s device'),
                    _buildSubStep('b', 'Tap the lock icon (bottom corner) → solve the math or enter your passcode'),
                    _buildSubStep('c', 'Go to Settings → select your child\'s profile → enter your parent password if asked'),
                    _buildSubStep('d', 'Tap Edit settings (under "Content settings")'),
                    _buildSubStep('e', 'Choose "Approve content yourself" and confirm'),
                    _buildSubStep('f', 'Select the channels/videos/collections you want to allow → tap Done'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildStep('4', 'Check out "Build a Watch List" for a starter list of high quality channels to approve'),
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
                      'Time to complete: ~5 minutes',
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
                'This process trains the YouTube algorithm away from junk content. Instantly removes that content creator from your child\'s feed — no more similar videos from them in the future.',
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
                        'Blocking inappropriate channels helps create a safer, more educational viewing environment for children.',
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
                'This works best when done with your child. It shows them why certain content isn\'t ideal — and that they have power over their feed.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.schedule,
                'Make it a monthly ritual: Sit down and scan the homepage with your child — talk through what to keep and what to toss.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.chat_bubble,
                'Use this as a teaching moment to discuss what makes content appropriate or inappropriate.',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.refresh,
                'Remember that you may need to repeat this process as new content appears.',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Content Rubric',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Source: Guidebook — Sage Parents',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              _buildContentTable(),
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

  Widget _buildSubStep(String letter, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildContentTable() {
    final contentTypes = [
      {
        'type': 'Style & beauty content (intended for teenagers)',
        'rationale': 'A lot of style and beauty content is intended for teenagers and adults. When young girls under 12 years old watch these videos, they often mimic this older behavior and "grow up more quickly."'
      },
      {
        'type': 'Overconsumption content',
        'rationale': 'Overconsumption content includes videos of kids buying toys, sharing clothing "hauls," etc. Exposing kids to excessive consumption can lead to feelings of insufficiency and unhealthy social comparisons.'
      },
      {
        'type': 'Vlog-style content',
        'rationale': 'Many vlog-style videos include someone recording their own personal experiences throughout the day and "broadcasting" their life. Kids mimic this and want to record their every move with friends online.'
      },
      {
        'type': 'Violent content',
        'rationale': 'Violent imagery and videos can be alarming or gory. Kids are especially vulnerable—violent imagery can negatively impact their mental health.'
      },
      {
        'type': 'Overtly sexual content',
        'rationale': 'Exposing kids to mature content can negatively impact their mental health. Try to limit overtly sexual content including certain celebrity videos, etc.'
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Types of Content to Limit/Avoid',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Text(
                  'Rationale from Child Development Experts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        ...contentTypes.map((item) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item['type']!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Text(
                  item['rationale']!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}