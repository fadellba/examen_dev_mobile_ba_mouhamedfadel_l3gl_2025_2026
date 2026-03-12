import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../models/task_status.dart';
import '../../../models/task_priority.dart';
import '../../../widgets/cards/task_card.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../tasks/task_detail_screen.dart';
import '../../tasks/task_form_screen.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();

    final selectedProject = projectProvider.selectedProject;

    if (selectedProject == null) {
      return const Center(
        child: Text("Veuillez sélectionner un projet dans l'onglet 'Projets'"),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip<TaskStatus>(
                  context,
                  label: "Statut",
                  currentValue: taskProvider.statusFilter,
                  values: TaskStatus.values,
                  onSelected: (val) => taskProvider.setStatusFilter(val),
                ),
                const SizedBox(width: 10),
                _buildFilterChip<TaskPriority>(
                  context,
                  label: "Priorite",
                  currentValue: taskProvider.priorityFilter,
                  values: TaskPriority.values,
                  onSelected: (val) => taskProvider.setPriorityFilter(val),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list_off),
                  onPressed: () => taskProvider.clearFilters(),
                  tooltip: "Reinitialiser",
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: taskProvider.isLoading
              ? const LoadingIndicator()
              : taskProvider.tasks.isEmpty
              ? const Center(child: Text("Aucune tache trouvee"))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return TaskCard(
                task: task,
                onTap: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: task),
                  ),
                );},
                onEdit: () => _showTaskForm(context, task),
                onDelete: () => taskProvider.deleteTask(task.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip<T extends Enum>(
      BuildContext context, {
        required String label,
        required T? currentValue,
        required List<T> values,
        required Function(T?) onSelected,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textDisable,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<T>(
        value: currentValue,
        hint: Text(label),
        underline: const SizedBox(),
        items: [
          DropdownMenuItem<T>(value: null, child: Text("Tous les ${label}s")),
          ...values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))),
        ],
        onChanged: onSelected,
      ),
    );
  }

  void _showTaskForm(BuildContext context, [Task? task]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
  }
}