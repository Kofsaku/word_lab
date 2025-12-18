import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stage_select_screen.dart';
import 'screens/input_training_screen.dart';
import 'screens/check_time_screen_v2.dart';
import 'screens/interest_input_screen.dart';
import 'screens/stage_test_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';
import 'screens/review_list_screen.dart';
import 'screens/help_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.initializeSampleData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          onPrimary: AppColors.textPrimary,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Hiragino Sans',
      ),
      locale: const Locale('ja', 'JP'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
            );
          case '/level-select':
            return MaterialPageRoute(
              builder: (context) => const LevelSelectScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
          case '/stage-select':
            return MaterialPageRoute(
              builder: (context) => const StageSelectScreen(),
            );
          case '/input-training':
            final stageId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => InputTrainingScreen(stageId: stageId),
            );
          case '/check-time':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CheckTimeScreenV2(
                stageId: args['stageId'],
                words: args['words'],
              ),
            );
          case '/interest-input':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => InterestInputScreen(
                stageId: args['stageId'],
                checkTimeResults: args['checkTimeResults'],
              ),
            );
          case '/stage-test':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StageTestScreen(
                stageId: args['stageId'],
                checkTimeResults: args['checkTimeResults'],
                userInterest: args['userInterest'],
              ),
            );
          case '/result':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ResultScreen(
                stageId: args['stageId'],
                testScore: args['testScore'],
                testCorrectCount: args['testCorrectCount'],
                testTotalCount: args['testTotalCount'],
                checkTimeCorrectCount: args['checkTimeCorrectCount'],
                checkTimeTotalCount: args['checkTimeTotalCount'],
              ),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            );
          case '/history':
            return MaterialPageRoute(
              builder: (context) => const HistoryScreen(),
            );
          case '/review-list':
            return MaterialPageRoute(
              builder: (context) => const ReviewListScreen(),
            );
          case '/help':
            return MaterialPageRoute(
              builder: (context) => const HelpScreen(),
            );
          case '/contact':
            return MaterialPageRoute(
              builder: (context) => const ContactScreen(),
            );
          case '/terms':
            return MaterialPageRoute(
              builder: (context) => const TermsScreen(),
            );
          case '/privacy':
            return MaterialPageRoute(
              builder: (context) => const PrivacyScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}
