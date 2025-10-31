import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/quick_action_base.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/quick_action_service.dart';

class WaitingTimeKitScreen extends StatefulWidget {
  const WaitingTimeKitScreen({super.key});

  @override
  State<WaitingTimeKitScreen> createState() => _WaitingTimeKitScreenState();
}

class _WaitingTimeKitScreenState extends State<WaitingTimeKitScreen> {
  final QuickActionService _quickActionService = QuickActionService();
  bool _isCompleted = false;
  bool _isLoading = false;
  final String actionId = 'waiting-time-kit';

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
      title: 'Make Waiting-Time Kits',
      isCompleted: _isCompleted,
      onCompletedChanged: _toggleCompletion,
      resources: const [
        ResourceItem(
          title: 'Screen-Free Activities for Kids',
          url: 'https://www.commonsensemedia.org/articles/screen-free-activities',
        ),
      ],
      content: [
        ContentCard(
          title: 'What is a Waiting-Time Kit?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A special bag or box filled with engaging activities that your child can use during waiting times instead of reaching for a screen.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
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
                      'Time to create: 15-20 minutes',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Kit Ideas by Age',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAgeKit(
                'Ages 3-5',
                [
                  'Small coloring book & crayons',
                  'Pipe cleaners for shaping',
                  'Sticker scenes',
                  'Mini puzzle (12-24 pieces)',
                  'Small fidget toy',
                ],
              ),
              const SizedBox(height: 16),
              _buildAgeKit(
                'Ages 6-8',
                [
                  'Activity book (mazes, word searches)',
                  'Small LEGO set',
                  'Travel-sized games',
                  'Audio stories on device',
                  'Drawing pad & pencils',
                ],
              ),
              const SizedBox(height: 16),
              _buildAgeKit(
                'Ages 9-12',
                [
                  'Brain teaser puzzles',
                  'Rubik\'s cube',
                  'Pocket notebook for stories',
                  'Card games',
                  'Origami paper & instructions',
                ],
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'Where to Use Your Kit',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocation(Icons.local_hospital, 'Doctor\'s waiting room'),
              _buildLocation(Icons.restaurant, 'Restaurants'),
              _buildLocation(Icons.directions_car, 'Car rides'),
              _buildLocation(Icons.shopping_cart, 'Grocery shopping'),
              _buildLocation(Icons.airplanemode_active, 'Airport/travel'),
              _buildLocation(Icons.cut, 'Hair salon'),
              _buildLocation(Icons.people, 'Waiting for siblings'),
            ],
          ),
        ),
        ContentCard(
          title: 'Pro Tips',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip(
                Icons.refresh,
                'Rotate items monthly to keep the kit fresh and exciting',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.backpack,
                'Keep one kit in the car and one in your regular bag',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.child_care,
                'Let your child help choose items for their kit',
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.star,
                'Save special items only for waiting times to maintain novelty',
              ),
            ],
          ),
        ),
        ContentCard(
          title: 'DIY Kit Container Ideas',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContainer('Small backpack', 'Easy for child to carry'),
              const SizedBox(height: 8),
              _buildContainer('Pencil box', 'Fits in parent\'s bag'),
              const SizedBox(height: 8),
              _buildContainer('Zippered pouch', 'Lightweight and flexible'),
              const SizedBox(height: 8),
              _buildContainer('Small lunchbox', 'Sturdy and organized'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgeKit(String ageGroup, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ageGroup,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLocation(IconData icon, String location) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Text(location, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildContainer(String type, String benefit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.backpack, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text(
                benefit,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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