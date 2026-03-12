import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  // Méthodes CRUD
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allProjects = _storage.getAllProjects();
      _projects = allProjects.where((p) => p.userId == userId).toList();
    } catch (e, stacktrace) {
      print("ERREUR TECHNIQUE : $e");
      print("STACKTRACE : $stacktrace");
      print("Erreur lors du chargement des projets.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProject(Project project) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.saveProject(project);
      _projects.add(project);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.saveProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}