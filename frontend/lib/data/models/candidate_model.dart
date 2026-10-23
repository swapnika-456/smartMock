class Candidate {
  final String name;
  final String targetRole;
  final int yearsOfExperience;
  final List<String> skills;
  final String? resumeSummary;

  Candidate({
    required this.name,
    required this.targetRole,
    required this.yearsOfExperience,
    required this.skills,
    this.resumeSummary,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'target_role': targetRole,
    'years_of_experience': yearsOfExperience,
    'skills': skills,
    'resume_summary': resumeSummary,
  };

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    name: json['name'] as String? ?? 'Candidate',
    targetRole: json['target_role'] as String? ?? 'Software Engineer',
    yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 2,
    skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    resumeSummary: json['summary'] as String? ?? json['resume_summary'] as String?,
  );
}
