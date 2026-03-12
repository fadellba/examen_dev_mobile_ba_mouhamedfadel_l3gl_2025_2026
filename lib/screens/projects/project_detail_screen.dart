import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import '../../models/project.dart';
import '../../models/task_status.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/cards/task_card.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().getTasksByProject(project.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(project.colorValue),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectFormScreen(project: project)),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(context)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Color(project.colorValue).withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(project.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStatChip("A faire", tasks.where((t) => t.status == TaskStatus.todo).length, AppColors.statusTodo),
                    _buildStatChip("En cours", tasks.where((t) => t.status == TaskStatus.inProgress).length, AppColors.statusInProgress),
                    _buildStatChip("Termine", tasks.where((t) => t.status == TaskStatus.done).length, AppColors.statusDone),
                  ],
                ),
                const SizedBox(height: 8),
                Chip(label: Text("${tasks.length} taches au total")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final task = tasks[i];
                return TaskCard(
                  task: task,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(task: task),
                      ),
                    );
                  },
                  onDelete: () {
                    context.read<TaskProvider>().deleteTask(task.id);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(project.colorValue),
        onPressed: () {
          context.read<ProjectProvider>().selectProject(project);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer le projet ?"),
        content: const Text("Toutes les taches liees seront supprimees definitivement."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              context.read<ProjectProvider>().deleteProject(project.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text("$label: $count", style: const TextStyle(fontSize: 11, color: AppColors.primary)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}