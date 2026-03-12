import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/task_status.dart';
import '../../models/task_priority.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = création, non-null = modification

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(text: widget.task?.description ?? "");
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildAnimatedSelector<T>({
    required String label,
    required T value,
    required List<T> options,
    required Function(T) onSelect,
    required Color activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            final isSelected = value == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : AppColors.textDisable,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: activeColor.withOpacity(0.5), width: 2) : null,
                  ),
                  child: Center(
                    child: Text(
                      option.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.secondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Nouvelle Tache" : "Modifier la Tache"),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: "Titre de la tache*",
                controller: _titleController,
                validator: (v) => (v == null || v.isEmpty) ? "Le titre est obligatoire" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Description",
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 25),

              _buildAnimatedSelector<TaskStatus>(
                label: "Statut",
                value: _selectedStatus,
                options: TaskStatus.values,
                activeColor: AppColors.primary,
                onSelect: (val) => setState(() => _selectedStatus = val),
              ),
              const SizedBox(height: 20),
              _buildAnimatedSelector<TaskPriority>(
                label: "Priorite",
                value: _selectedPriority,
                options: TaskPriority.values,
                activeColor: AppColors.warning,
                onSelect: (val) => setState(() => _selectedPriority = val),
              ),
              const SizedBox(height: 25),

              ListTile(
                title: const Text("Echeance"),
                subtitle: Text(_selectedDate == null
                    ? "Choisir une date"
                    : DateFormat('dd MMMM yyyy').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
                tileColor: AppColors.textDisable,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),

              const SizedBox(height: 40),
              CustomButton(
                text: widget.task == null ? "Creer la tache" : "Enregistrer",
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final projectProvider = context.read<ProjectProvider>();
    final projectId = projectProvider.selectedProject?.id;

    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Action impossible : Aucun projet n'est selectionne."),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      projectId: projectId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _selectedDate,
    );

    try {
      if (widget.task == null) {
        await context.read<TaskProvider>().createTask(task);
      } else {
        await context.read<TaskProvider>().updateTask(task);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sauvegarde : $e")),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer la tache ?"),
        content: const Text("Cette action est irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              await context.read<TaskProvider>().deleteTask(widget.task!.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}