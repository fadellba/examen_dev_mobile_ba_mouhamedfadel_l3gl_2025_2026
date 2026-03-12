import 'task_status.dart';
import 'task_priority.dart';

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'projectId': projectId,
    'title': title,
    'description': description,
    'status': status.name,
    'priority': priority.name,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    projectId: map['projectId'],
    title: map['title'],
    description: map['description'],
    status: TaskStatus.values.byName(map['status']),
    priority: TaskPriority.values.byName(map['priority']),
    dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
  );
}