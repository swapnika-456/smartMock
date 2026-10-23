import 'package:flutter/material.dart';
import '../../core/theme.dart';

class StageProgressIndicator extends StatelessWidget {
  final String stage;
  final int currentQuestion;
  final int totalQuestions;

  const StageProgressIndicator({
    super.key,
    required this.stage,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final isTech = stage.toLowerCase() == 'technical';
    final isBeh = stage.toLowerCase() == 'behavioral';
    final progress = totalQuestions > 0 ? (currentQuestion / totalQuestions).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isTech
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : isBeh
                          ? AppTheme.accent.withValues(alpha: 0.2)
                          : AppTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isTech
                        ? AppTheme.primary
                        : isBeh
                            ? AppTheme.accent
                            : AppTheme.success,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTech
                          ? Icons.code_rounded
                          : isBeh
                              ? Icons.people_outline_rounded
                              : Icons.check_circle_outline,
                      size: 15,
                      color: isTech
                          ? AppTheme.primaryLight
                          : isBeh
                              ? AppTheme.accent
                              : AppTheme.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTech
                          ? 'ROUND 1: TECHNICAL INTERVIEW'
                          : isBeh
                              ? 'ROUND 2: BEHAVIORAL & SITUATIONAL'
                              : 'INTERVIEW COMPLETED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isTech
                            ? AppTheme.primaryLight
                            : isBeh
                                ? AppTheme.accent
                                : AppTheme.success,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Question $currentQuestion of $totalQuestions',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTech ? AppTheme.primary : AppTheme.accent,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
