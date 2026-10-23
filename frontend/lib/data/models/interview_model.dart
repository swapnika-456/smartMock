class InterviewTurn {
  final String role;
  final String content;
  final String stage;
  final String timestamp;

  InterviewTurn({
    required this.role,
    required this.content,
    required this.stage,
    required this.timestamp,
  });

  factory InterviewTurn.fromJson(Map<String, dynamic> json) => InterviewTurn(
    role: json['role'] as String? ?? 'assistant',
    content: json['content'] as String? ?? '',
    stage: json['stage'] as String? ?? 'technical',
    timestamp: json['timestamp'] as String? ?? '',
  );
}

class NextQuestionResult {
  final String sessionId;
  final String stage;
  final String question;
  final int questionNumber;
  final int totalQuestions;
  final bool isStageTransition;
  final bool isCompleted;

  NextQuestionResult({
    required this.sessionId,
    required this.stage,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.isStageTransition,
    required this.isCompleted,
  });

  factory NextQuestionResult.fromJson(Map<String, dynamic> json) => NextQuestionResult(
    sessionId: json['session_id'] as String? ?? '',
    stage: json['stage'] as String? ?? 'technical',
    question: json['question'] as String? ?? '',
    questionNumber: (json['question_number'] as num?)?.toInt() ?? 1,
    totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 4,
    isStageTransition: json['is_stage_transition'] as bool? ?? false,
    isCompleted: json['is_completed'] as bool? ?? false,
  );
}
