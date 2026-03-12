import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../models/task_status.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectCount = context.watch<ProjectProvider>().projectCount;
    final tasks = context.watch<TaskProvider>().tasks;

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vue d'ensemble",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                context,
                "Projets",
                projectCount.toString(),
                Icons.folder_special,
                AppColors.primary,
              ),
              _buildStatCard(
                context,
                "Taches totales",
                totalTasks.toString(),
                Icons.assignment,
                AppColors.warning,
              ),
              _buildStatCard(
                context,
                "Terminees",
                completedTasks.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
              _buildStatCard(
                context,
                "Taux de succes",
                "${(completionRate * 100).toStringAsFixed(0)}%",
                Icons.trending_up,
                AppColors.info,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Progression globale",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionRate,
            minHeight: 10,
            backgroundColor: AppColors.textDisable,
            color: AppColors.success,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}