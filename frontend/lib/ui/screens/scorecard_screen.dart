import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/evaluation_model.dart';
import '../view_models/interview_view_model.dart';

class ScorecardScreen extends StatelessWidget {
  const ScorecardScreen({super.key});

  Color _getScoreColor(int score) {
    if (score >= 85) return AppTheme.success;
    if (score >= 70) return AppTheme.accent;
    if (score >= 55) return AppTheme.warning;
    return AppTheme.danger;
  }

  String _generateMarkdownReport(EvaluationReport report) {
    final sb = StringBuffer();
    sb.writeln('# 🎯 smartMock Evaluation Scorecard');
    sb.writeln('**Candidate:** ${report.candidateName}');
    sb.writeln('**Target Role:** ${report.targetRole}');
    sb.writeln('**Overall Score:** ${report.overallScore}/100');
    sb.writeln('**Hiring Recommendation:** ${report.recommendation.toUpperCase()}\n');
    sb.writeln('## Executive Summary\n${report.executiveSummary}\n');
    sb.writeln('## Competency Pillars');
    sb.writeln('- Technical Depth: ${report.technicalScore}%');
    sb.writeln('- Problem Solving: ${report.problemSolvingScore}%');
    sb.writeln('- Communication: ${report.communicationScore}%');
    sb.writeln('- Behavioral Fit: ${report.behavioralScore}%\n');
    sb.writeln('## Key Strengths');
    for (final s in report.strengths) {
      sb.writeln('- $s');
    }
    sb.writeln('\n## Areas to Refine');
    for (final w in report.weaknesses) {
      sb.writeln('- $w');
    }
    sb.writeln('\n## Topic Assessment');
    for (final t in report.topicScores) {
      sb.writeln('### ${t.topic} (${t.score}/100)');
      sb.writeln('${t.feedback}\n');
    }
    sb.writeln('## Personalized Action Plan');
    for (var i = 0; i < report.actionPlan.length; i++) {
      sb.writeln('${i + 1}. ${report.actionPlan[i]}');
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InterviewViewModel>();
    final report = vm.evaluationReport;

    if (report == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text('Synthesizing evaluation metrics with OpenAI...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: vm.resetToHome,
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final scoreColor = _getScoreColor(report.overallScore);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Candidate Evaluation & Scorecard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              final md = _generateMarkdownReport(report);
              Clipboard.setData(ClipboardData(text: md));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scorecard report copied to clipboard!'),
                  backgroundColor: AppTheme.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.accent),
            label: const Text('Copy Report', style: TextStyle(color: AppTheme.accent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.accent),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: vm.resetToHome,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('New Interview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Hero Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: scoreColor, width: 6),
                            color: scoreColor.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${report.overallScore}',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: scoreColor,
                                  ),
                                ),
                                const Text(
                                  '/ 100',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    report.candidateName,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: scoreColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: scoreColor),
                                    ),
                                    child: Text(
                                      report.recommendation.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: scoreColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                report.targetRole,
                                style: const TextStyle(fontSize: 15, color: AppTheme.accent, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                report.executiveSummary,
                                style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Core Competency Breakdown Grid
                const Text(
                  'Core Competency Pillars',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('Technical Depth', report.technicalScore, Icons.code_rounded)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildMetricTile('Problem Solving', report.problemSolvingScore, Icons.architecture_rounded)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildMetricTile('Communication', report.communicationScore, Icons.chat_bubble_outline_rounded)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildMetricTile('Behavioral & Culture', report.behavioralScore, Icons.groups_outlined)),
                  ],
                ),
                const SizedBox(height: 28),

                // Topic Breakdown
                const Text(
                  'Topic-by-Topic Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ...report.topicScores.map((ts) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ts.topic,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${ts.score} / 100',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(ts.score),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ts.score / 100.0,
                                minHeight: 6,
                                backgroundColor: AppTheme.surfaceBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(ts.score)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ts.feedback,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 20),

                // Strengths and Weaknesses
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: AppTheme.success, size: 20),
                                  SizedBox(width: 8),
                                  Text('Key Strengths', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...report.strengths.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(color: AppTheme.success, fontSize: 16)),
                                        Expanded(
                                          child: Text(s, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.trending_up_rounded, color: AppTheme.warning, size: 20),
                                  SizedBox(width: 8),
                                  Text('Areas to Refine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...report.weaknesses.map((w) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(color: AppTheme.warning, fontSize: 16)),
                                        Expanded(
                                          child: Text(w, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Plan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flag_outlined, color: AppTheme.accent, size: 20),
                            SizedBox(width: 8),
                            Text('Personalized Action & Study Roadmap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...report.actionPlan.asMap().entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(entry.value, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, int score, IconData icon) {
    final color = _getScoreColor(score);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary)),
                const Spacer(),
                Text(
                  '$score%',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100.0,
                minHeight: 6,
                backgroundColor: AppTheme.surfaceBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
