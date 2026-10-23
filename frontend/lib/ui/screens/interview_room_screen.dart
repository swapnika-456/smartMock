import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../view_models/interview_view_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/stage_progress_indicator.dart';

class InterviewRoomScreen extends StatefulWidget {
  const InterviewRoomScreen({super.key});

  @override
  State<InterviewRoomScreen> createState() => _InterviewRoomScreenState();
}

class _InterviewRoomScreenState extends State<InterviewRoomScreen> {
  final _answerController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    _answerController.clear();
    final vm = context.read<InterviewViewModel>();
    await vm.submitAnswer(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InterviewViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryLight, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'smartMock AI Interview Room',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  vm.candidate != null ? '${vm.candidate!.name} • ${vm.candidate!.targetRole}' : 'Session Active',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surfaceCard,
                  title: const Text('End Interview?'),
                  content: const Text('Would you like to finish early and generate your evaluation scorecard?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        vm.loadEvaluation();
                      },
                      child: const Text('Generate Scorecard'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text('Scorecard'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StageProgressIndicator(
                  stage: vm.currentStage,
                  currentQuestion: vm.questionNumber,
                  totalQuestions: vm.totalQuestionsInStage,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(turn: vm.messages[index]);
                  },
                ),
              ),

              if (vm.isSubmittingAnswer)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Alex is analyzing your answer and preparing next question...',
                        style: TextStyle(color: AppTheme.accent, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 15, color: AppTheme.warning),
                        const SizedBox(width: 6),
                        Text(
                          vm.currentStage.toLowerCase() == 'technical'
                              ? 'Tip: Explain technical trade-offs, time/space complexity, and edge cases.'
                              : 'Tip: Use the STAR framework (Situation, Task, Action, Result) for behavioral answers.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerController,
                            minLines: 1,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'Type your answer or code solution here...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onSubmitted: (_) => _submitAnswer(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: vm.isSubmittingAnswer ? null : _submitAnswer,
                          icon: const Icon(Icons.send_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
