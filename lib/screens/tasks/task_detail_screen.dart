import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import '../../models/task_status.dart';
import '../../models/task_priority.dart';
import '../../providers/task_provider.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final currentTask = taskProvider.tasks.firstWhere((t) => t.id == task.id, orElse: () => task);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details de la tache"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormScreen(task: currentTask))
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () {
              context.read<TaskProvider>().deleteTask(currentTask.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentTask.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildPriorityBadge(currentTask.priority),
              ],
            ),
            const SizedBox(height: 15),

            const Text("Statut", style: TextStyle(color: AppColors.textDisable, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatusSelector(context, currentTask, taskProvider),

            const Divider(height: 40),

            const Text("Description", style: TextStyle(color: AppColors.textDisable, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              currentTask.description.isEmpty ? "Aucune description" : currentTask.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Text("Date d'échéance", style: TextStyle(color: AppColors.textDisable, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: AppColors.info),
                const SizedBox(width: 10),
                Text(
                  currentTask.dueDate == null
                      ? "Pas de date fixee"
                      : DateFormat('EEEE dd MMMM yyyy').format(currentTask.dueDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high: color = AppColors.error; break;
      case TaskPriority.medium: color = AppColors.warning; break;
      case TaskPriority.low: color = AppColors.success; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusSelector(BuildContext context, Task task, TaskProvider provider) {
    return Wrap(
      spacing: 8,
      children: TaskStatus.values.map((status) {
        final isSelected = task.status == status;
        return ChoiceChip(
          label: Text(status.name),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              final updatedTask = task.copyWith(status: status);
              provider.updateTask(updatedTask);
            }
          },
        );
      }).toList(),
    );
  }
}