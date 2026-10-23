class TopicScore {
  final String topic;
  final int score;
  final String feedback;

  TopicScore({
    required this.topic,
    required this.score,
    required this.feedback,
  });

  factory TopicScore.fromJson(Map<String, dynamic> json) => TopicScore(
    topic: json['topic'] as String? ?? '',
    score: (json['score'] as num?)?.toInt() ?? 80,
    feedback: json['feedback'] as String? ?? '',
  );
}

class EvaluationReport {
  final String sessionId;
  final String candidateName;
  final String targetRole;
  final int overallScore;
  final int technicalScore;
  final int problemSolvingScore;
  final int communicationScore;
  final int behavioralScore;
  final String recommendation;
  final String executiveSummary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<TopicScore> topicScores;
  final List<String> actionPlan;

  EvaluationReport({
    required this.sessionId,
    required this.candidateName,
    required this.targetRole,
    required this.overallScore,
    required this.technicalScore,
    required this.problemSolvingScore,
    required this.communicationScore,
    required this.behavioralScore,
    required this.recommendation,
    required this.executiveSummary,
    required this.strengths,
    required this.weaknesses,
    required this.topicScores,
    required this.actionPlan,
  });

  factory EvaluationReport.fromJson(Map<String, dynamic> json) => EvaluationReport(
    sessionId: json['session_id'] as String? ?? '',
    candidateName: json['candidate_name'] as String? ?? 'Candidate',
    targetRole: json['target_role'] as String? ?? '',
    overallScore: (json['overall_score'] as num?)?.toInt() ?? 85,
    technicalScore: (json['technical_score'] as num?)?.toInt() ?? 85,
    problemSolvingScore: (json['problem_solving_score'] as num?)?.toInt() ?? 85,
    communicationScore: (json['communication_score'] as num?)?.toInt() ?? 85,
    behavioralScore: (json['behavioral_score'] as num?)?.toInt() ?? 85,
    recommendation: json['recommendation'] as String? ?? 'Hire',
    executiveSummary: json['executive_summary'] as String? ?? '',
    strengths: (json['strengths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    weaknesses: (json['weaknesses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    topicScores: (json['topic_scores'] as List<dynamic>?)
            ?.map((e) => TopicScore.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    actionPlan: (json['action_plan'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );
}
