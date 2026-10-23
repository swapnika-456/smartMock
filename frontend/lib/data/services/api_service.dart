import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/candidate_model.dart';
import '../models/interview_model.dart';
import '../models/evaluation_model.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConstants.baseUrl;

  Future<Candidate> parseResume(Uint8List fileBytes, String filename) async {
    final uri = Uri.parse('$_baseUrl/api/v1/candidate/parse-resume');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Candidate.fromJson(json);
    } else {
      throw Exception('Failed to parse resume: ${response.body}');
    }
  }

  Future<NextQuestionResult> startInterview({
    required Candidate candidate,
    int totalTechQuestions = 4,
    int totalBehavioralQuestions = 3,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/interview/start');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'candidate': candidate.toJson(),
        'total_technical_questions': totalTechQuestions,
        'total_behavioral_questions': totalBehavioralQuestions,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return NextQuestionResult.fromJson(json);
    } else {
      throw Exception('Failed to start interview: ${response.body}');
    }
  }

  Future<NextQuestionResult> submitAnswer({
    required String sessionId,
    required String answer,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/interview/$sessionId/answer');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'answer': answer}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return NextQuestionResult.fromJson(json);
    } else {
      throw Exception('Failed to submit answer: ${response.body}');
    }
  }

  Future<EvaluationReport> fetchEvaluation(String sessionId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/evaluation/$sessionId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return EvaluationReport.fromJson(json);
    } else {
      throw Exception('Failed to fetch evaluation report: ${response.body}');
    }
  }
}
