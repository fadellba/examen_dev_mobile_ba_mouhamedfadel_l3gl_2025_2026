import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/project.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late int _colorValue;

  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.project?.name ?? "";
    _description = widget.project?.description ?? "";
    _colorValue = widget.project?.colorValue ?? _colors[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.project == null ? "Nouveau Projet" : "Modifier")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onChanged: (v) => setState(() => _description = v),
              ),
              const SizedBox(height: 20),
              const Text("Choisir une couleur :"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colors.map((color) => GestureDetector(
                  onTap: () => setState(() => _colorValue = color.value),
                  child: CircleAvatar(
                    backgroundColor: color,
                    child: _colorValue == color.value ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.project == null ? "Creer" : "Modifier"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final projectProvider = context.read<ProjectProvider>();
    final auth = context.read<AuthProvider>();

    final project = Project(
      id: widget.project?.id ?? const Uuid().v4(),
      name: _name,
      description: _description,
      colorValue: _colorValue,
      userId: auth.currentUser!.id,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
    );

    widget.project == null ? projectProvider.createProject(project) : projectProvider.updateProject(project);
    Navigator.pop(context);
  }
}