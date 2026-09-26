import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'data/models/habit_model.dart';
import 'data/models/profile_model.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<ProfileModel>('profile');

  await NotificationService().init();

  runApp(const StreaksApp());
}

class StreaksApp extends StatelessWidget {
  const StreaksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box<ProfileModel>('profile');
    final hasProfile = profileBox.isNotEmpty;

    return MaterialApp(
      title: 'Streaks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: hasProfile ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}
