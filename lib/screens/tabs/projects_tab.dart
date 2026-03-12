import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/project.dart';
import '../../../providers/project_provider.dart';
import '../../../widgets/cards/project_card.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../projects/project_detail_screen.dart';
import '../../projects/project_form_screen.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;

    if (projectProvider.isLoading) {
      return const LoadingIndicator(message: "Chargement de vos projets...");
    }

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: AppColors.textDisable),
            const SizedBox(height: 16),
            const Text(
              "Aucun projet pour le moment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Cliquez sur le bouton + pour en créer un."),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          onTap: () {
            projectProvider.selectProject(project);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(project: project),
              ),
            );
          },
          onEdit: () {
            _showProjectForm(context, project);
          },
          onDelete: () {
            _confirmDelete(context, projectProvider, project.id);
          },
        );
      },
    );
  }

  void _showProjectForm(BuildContext context, [Project? project]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectFormScreen(project: project),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProjectProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer le projet ?"),
        content: const Text("Cela supprimera également toutes les tâches associées."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              provider.deleteProject(id);
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}