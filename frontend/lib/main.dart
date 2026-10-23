import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'ui/view_models/interview_view_model.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/interview_room_screen.dart';
import 'ui/screens/scorecard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InterviewViewModel()),
      ],
      child: const SmartMockApp(),
    ),
  );
}

class SmartMockApp extends StatelessWidget {
  const SmartMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootNavigator(),
    );
  }
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final step = context.select<InterviewViewModel, AppViewStep>(
      (vm) => vm.currentStep,
    );

    switch (step) {
      case AppViewStep.welcome:
        return const WelcomeScreen();
      case AppViewStep.interview:
        return const InterviewRoomScreen();
      case AppViewStep.scorecard:
        return const ScorecardScreen();
    }
  }
}
