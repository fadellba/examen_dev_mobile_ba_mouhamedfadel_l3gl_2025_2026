import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/models/task_priority.dart';
import 'package:sunu_task/models/task_status.dart';
import 'package:sunu_task/services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  List<Task> _allTasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  bool get isLoading => _isLoading;

  List<Task> getTasksByProject(String projectId) {
    return _allTasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> get tasks {
    List<Task> filteredTasks = _allTasks;

    if (_statusFilter != null) {
      filteredTasks = filteredTasks.where((t) => t.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      filteredTasks = filteredTasks.where((t) => t.priority == _priorityFilter).toList();
    }

    filteredTasks.sort((a, b) {
      int statusComp = _statusWeight(a.status).compareTo(_statusWeight(b.status));
      if (statusComp != 0) return statusComp;
      return _priorityWeight(a.priority).compareTo(_priorityWeight(b.priority));
    });

    return filteredTasks;
  }  // Retourne les tâches filtrées et triées

  int _statusWeight(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress: return 0;
      case TaskStatus.todo: return 1;
      case TaskStatus.done: return 2;
    }
  }

  int _priorityWeight(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return 0;
      case TaskPriority.medium: return 1;
      case TaskPriority.low: return 2;
    }
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allTasks = _storage.getAllTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTaskByProject(String projectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final all = _storage.getAllTasks();
      _allTasks = all.where((t) => t.projectId == projectId).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    await _storage.saveTask(task);
    _allTasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _storage.saveTask(task);
    int index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _allTasks[index] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _storage.deleteOneTask(taskId);
    _allTasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}