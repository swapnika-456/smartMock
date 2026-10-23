import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static const String appTitle = 'smartMock — AI Interview Coach';

  static const List<String> defaultRoles = [
    'Senior Full-Stack Engineer',
    'Python Backend Developer',
    'Flutter & Mobile Engineer',
    'AI / Machine Learning Engineer',
    'DevOps & Cloud Architect',
    'Frontend React Specialist',
  ];

  static const List<String> popularSkills = [
    'Python', 'FastAPI', 'Flutter', 'Dart', 'React',
    'PostgreSQL', 'Docker', 'Kubernetes', 'System Design',
    'GraphQL', 'AWS', 'Redis', 'CI/CD', 'OpenAI API'
  ];
}
