import 'package:flutter/foundation.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/interview_model.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/services/api_service.dart';

enum AppViewStep { welcome, interview, scorecard }

class InterviewViewModel extends ChangeNotifier {
  final ApiService _apiService;

  InterviewViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  AppViewStep _currentStep = AppViewStep.welcome;
  AppViewStep get currentStep => _currentStep;

  Candidate? _candidate;
  Candidate? get candidate => _candidate;

  String? _sessionId;
  String? get sessionId => _sessionId;

  String _currentStage = 'technical';
  String get currentStage => _currentStage;

  int _questionNumber = 1;
  int get questionNumber => _questionNumber;

  int _totalQuestionsInStage = 4;
  int get totalQuestionsInStage => _totalQuestionsInStage;

  final List<InterviewTurn> _messages = [];
  List<InterviewTurn> get messages => List.unmodifiable(_messages);

  EvaluationReport? _evaluationReport;
  EvaluationReport? get evaluationReport => _evaluationReport;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmittingAnswer = false;
  bool get isSubmittingAnswer => _isSubmittingAnswer;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> uploadResume(Uint8List bytes, String filename) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _candidate = await _apiService.parseResume(bytes, filename);
    } catch (e) {
      _errorMessage = 'Resume parsing error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCandidateProfile(Candidate candidate) {
    _candidate = candidate;
    notifyListeners();
  }

  Future<void> startInterview({
    required Candidate candidate,
    int totalTechQuestions = 4,
    int totalBehavioralQuestions = 3,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _candidate = candidate;
    _messages.clear();
    _evaluationReport = null;
    notifyListeners();

    try {
      final result = await _apiService.startInterview(
        candidate: candidate,
        totalTechQuestions: totalTechQuestions,
        totalBehavioralQuestions: totalBehavioralQuestions,
      );

      _sessionId = result.sessionId;
      _currentStage = result.stage;
      _questionNumber = result.questionNumber;
      _totalQuestionsInStage = result.totalQuestions;

      _messages.add(
        InterviewTurn(
          role: 'assistant',
          content: result.question,
          stage: result.stage,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );

      _currentStep = AppViewStep.interview;
    } catch (e) {
      _errorMessage = 'Could not start interview: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String answerText) async {
    if (_sessionId == null || answerText.trim().isEmpty) return;

    _isSubmittingAnswer = true;
    _errorMessage = null;

    final userTurn = InterviewTurn(
      role: 'candidate',
      content: answerText.trim(),
      stage: _currentStage,
      timestamp: DateTime.now().toIso8601String(),
    );
    _messages.add(userTurn);
    notifyListeners();

    try {
      final result = await _apiService.submitAnswer(
        sessionId: _sessionId!,
        answer: answerText.trim(),
      );

      _currentStage = result.stage;
      _questionNumber = result.questionNumber;
      _totalQuestionsInStage = result.totalQuestions;

      _messages.add(
        InterviewTurn(
          role: 'assistant',
          content: result.question,
          stage: result.stage,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );

      if (result.isCompleted) {
        await loadEvaluation();
      }
    } catch (e) {
      _errorMessage = 'Failed to submit answer: $e';
    } finally {
      _isSubmittingAnswer = false;
      notifyListeners();
    }
  }

  Future<void> loadEvaluation() async {
    if (_sessionId == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _evaluationReport = await _apiService.fetchEvaluation(_sessionId!);
      _currentStep = AppViewStep.scorecard;
    } catch (e) {
      _errorMessage = 'Evaluation generation error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetToHome() {
    _currentStep = AppViewStep.welcome;
    _sessionId = null;
    _messages.clear();
    _evaluationReport = null;
    _errorMessage = null;
    notifyListeners();
  }
}
