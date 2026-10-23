import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models/candidate_model.dart';
import '../view_models/interview_view_model.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController(text: 'Alex Mercer');
  final _roleController = TextEditingController(text: 'Senior Full-Stack Engineer');
  final _skillsController = TextEditingController(text: 'Python, FastAPI, Flutter, PostgreSQL, Docker, System Design');
  int _yearsOfExperience = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final vm = context.read<InterviewViewModel>();
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.xFile.readAsBytes();
      await vm.uploadResume(bytes, file.name);
      if (vm.candidate != null) {
        setState(() {
          _nameController.text = vm.candidate!.name;
          _roleController.text = vm.candidate!.targetRole;
          _yearsOfExperience = vm.candidate!.yearsOfExperience;
          _skillsController.text = vm.candidate!.skills.join(', ');
        });
      }
    }
  }

  void _startInterview() {
    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final candidate = Candidate(
      name: _nameController.text.trim().isEmpty ? 'Candidate' : _nameController.text.trim(),
      targetRole: _roleController.text.trim().isEmpty ? 'Software Engineer' : _roleController.text.trim(),
      yearsOfExperience: _yearsOfExperience,
      skills: skillsList.isEmpty ? ['Python', 'System Design'] : skillsList,
    );

    context.read<InterviewViewModel>().startInterview(candidate: candidate);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InterviewViewModel>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.2),
                          AppTheme.accent.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.accent, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'AI-POWERED MULTI-STAGE INTERVIEW COACH',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'smartMock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulate high-stakes tech & behavioral interviews with OpenAI GPT-4o. Get real-time follow-ups, depth probing, and a 360° rubric scorecard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 32),

                if (vm.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.danger),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.danger, size: 18),
                          onPressed: vm.clearError,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Resume Upload Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.upload_file_rounded, color: AppTheme.primaryLight, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-Fill from Resume',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Upload PDF or TXT to automatically extract candidate profile & skills',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: vm.isLoading ? null : _pickResume,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: vm.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Upload Resume'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Manual Profile Configuration Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Candidate Profile & Target Role',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),

                        // Name
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Candidate Name',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Target Role
                        TextField(
                          controller: _roleController,
                          decoration: const InputDecoration(
                            labelText: 'Target Job Title / Role',
                            prefixIcon: Icon(Icons.work_outline, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quick Role Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.defaultRoles.map((role) {
                            return ActionChip(
                              label: Text(role, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppTheme.surface,
                              side: const BorderSide(color: AppTheme.surfaceBorder),
                              onPressed: () {
                                setState(() {
                                  _roleController.text = role;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Experience Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Years of Experience:',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            Text(
                              '$_yearsOfExperience ${_yearsOfExperience == 1 ? "year" : "years"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _yearsOfExperience.toDouble(),
                          min: 0,
                          max: 15,
                          divisions: 15,
                          activeColor: AppTheme.accent,
                          inactiveColor: AppTheme.surfaceBorder,
                          onChanged: (val) {
                            setState(() {
                              _yearsOfExperience = val.toInt();
                            });
                          },
                        ),
                        const SizedBox(height: 14),

                        // Skills
                        TextField(
                          controller: _skillsController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Key Skills (comma separated)',
                            hintText: 'e.g., Python, FastAPI, PostgreSQL, Flutter, Docker',
                            prefixIcon: Icon(Icons.psychology_outlined, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Start Button
                ElevatedButton(
                  onPressed: vm.isLoading ? null : _startInterview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.primary,
                  ),
                  child: vm.isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Preparing AI Interviewer...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start smartMock Interview',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
