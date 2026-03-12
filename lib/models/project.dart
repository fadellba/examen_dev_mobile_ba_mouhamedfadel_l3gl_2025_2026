class Project {
  final String id;
  final String name;
  final String description;
  final int colorValue;
  final String userId;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'colorValue': colorValue,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    colorValue: map['colorValue'],
    userId: map['userId'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}