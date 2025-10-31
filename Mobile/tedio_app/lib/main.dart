import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/insights_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/quick_actions_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/relevancy_screen.dart';
import 'presentation/screens/quick_actions/remove_shorts_screen.dart';
import 'presentation/screens/quick_actions/waiting_time_kit_screen.dart';
import 'presentation/screens/quick_actions/pause_predict_screen.dart';
import 'presentation/screens/quick_actions/time_together_screen.dart';
import 'presentation/screens/quick_actions/build_watchlist_screen.dart';
import 'presentation/screens/quick_actions/set_timer_screen.dart';
import 'presentation/screens/quick_actions/physical_timer_screen.dart';
import 'presentation/screens/quick_actions/set_downtime_screen.dart';
import 'presentation/screens/quick_actions/remove_devices_screen.dart';
import 'presentation/screens/quick_actions/block_channel_screen.dart';

void main() {
  runApp(const MyApp());
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature is coming soon!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
      ],
      child: MaterialApp(
        title: 'Tedio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/quick-actions': (context) => const QuickActionsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/relevancy': (context) => const RelevancyScreen(),
          // Quick Action screens
          '/remove-shorts': (context) => const RemoveShortsScreen(),
          '/waiting-time-kit': (context) => const WaitingTimeKitScreen(),
          '/pause-predict': (context) => const PausePredictScreen(),
          '/time-together': (context) => const TimeTogetherScreen(),
          '/build-watchlist': (context) => const BuildWatchlistScreen(),
          '/set-timer': (context) => const SetTimerScreen(),
          '/physical-timer': (context) => const PhysicalTimerScreen(),
          '/set-downtime': (context) => const SetDowntimeScreen(),
          '/remove-devices': (context) => const RemoveDevicesScreen(),
          '/block-channel': (context) => const BlockChannelScreen(),
        },
      ),
    );
  }
}
