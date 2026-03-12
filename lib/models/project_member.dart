class ProjectMember {
  final String id;
  final String userId;
  final String projectId;
  final String role;

  ProjectMember({required this.id, required this.userId, required this.projectId, required this.role});

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'projectId': projectId,
    'role': role,
  };

  factory ProjectMember.fromMap(Map<String, dynamic> map) => ProjectMember(
    id: map['id'],
    userId: map['userId'],
    projectId: map['projectId'],
    role: map['role'],
  );
}