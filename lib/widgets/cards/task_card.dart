import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import '../../models/task.dart';
import '../../models/task_status.dart';
import '../../models/task_priority.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low: return AppColors.priorityLow;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return Icons.circle_outlined;
      case TaskStatus.inProgress: return Icons.pending_outlined;
      case TaskStatus.done: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          _getStatusIcon(task.status),
          color: task.status == TaskStatus.done ? AppColors.statusDone : AppColors.statusTodo,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.done
                ? TextDecoration.lineThrough
                : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            // Badge de priorité
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getPriorityColor(task.priority)),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  color: _getPriorityColor(task.priority),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}