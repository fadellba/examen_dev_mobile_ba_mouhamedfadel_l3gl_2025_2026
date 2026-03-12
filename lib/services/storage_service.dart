import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';
import '../models/project.dart';
import '../models/task.dart';

/// Pattern Singleton:
/// Pour avoir une seule instance
class StorageService {
  //===== Singleton ==========
  /// Instance Unique (privee)
  //static StorageService? _instance;
  static final StorageService instance = StorageService._internal();

  /// Getter pour acceder a l'instance
  // static StorageService get instance {
  //   _instance ??= StorageService._();
  //   return _instance!;
  // }

  /// Constructeur prive
  //StorageService._();
  StorageService._internal();

  //===== SharedPreferences ==========
  /// SharedPreferences utilise des opérations asynchrones
  /// car il lit/ecrtit sur le disque
  ///
  /// Le mot-cle await attend que l'operation se termine
  /// La fonction doit etre marque async et retourner un Future
  /// Les variables doivent être marqué par late
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    print("StorageService initialise avec succe"); // Pour vérifier dans ta console
  }

  //Cles de Stockage
  static const String _keyOnboardingConmplete = 'onboarding_complete';


  void _checkInitialized() {
    if (!_initialized) throw Exception("StorageService non initialisé. Appelez init() d'abord.");
  }

  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingConmplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingConmplete, value);
  }

  static const String _keyUsers = 'all_users';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyProjects = 'all_projects';
  static const String _keyTasks = 'all_tasks';

  /// GESTION DES UTILISATEURS
  // List<User> getAllUsers() {
  //   final String? usersJson = _prefs.getString(_keyUsers);
  //   if (usersJson == null) return [];
  //   final List<dynamic> decodedList = jsonDecode(usersJson);
  //   return decodedList.map((item) => User.fromMap(item)).toList();
  // }

  // List<User> getAllUsers() {
  //   _checkInitialized(); // Sécurité
  //   final String? usersJson = _prefs.getString(_keyUsers);
  //   if (usersJson == null) return [];
  //   try {
  //     final List<dynamic> decodedList = jsonDecode(usersJson);
  //     return decodedList.map((item) => User.fromMap(item)).toList();
  //   } catch (e) {
  //     print("Erreur décodage users: $e");
  //     return [];
  //   }
  // }

  List<User> getAllUsers() {
    try {
      final String? usersJson = _prefs.getString(_keyUsers);
      if (usersJson == null || usersJson.isEmpty) return [];

      final List<dynamic> decodedList = jsonDecode(usersJson);

      // Utilise .map().toList() mais avec une vérification de type
      return decodedList.map((item) {
        if (item is Map<String, dynamic>) {
          return User.fromMap(item);
        }
        return null;
      }).whereType<User>().toList(); // .whereType<User>() retire les potentiels nulls

    } catch (e) {
      debugPrint("Erreur critique décodage : $e");
      return [];
    }
  }

  Future<void> saveUser(User user) async {
    final List<User> users = getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
    } else {
      users.add(user);
    }
    final String encodedData = jsonEncode(users.map((u) => u.toMap()).toList());
    await _prefs.setString(_keyUsers, encodedData);
  }

  /// GESTION DE LA SESSION
  Future<void> saveCurrentUser(User user) async {
    final String userJson = jsonEncode(user.toMap());
    await _prefs.setString(_keyCurrentUser, userJson);
  }

  User? getCurrentUser() {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson));
  }

  Future<void> removeCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  /// GESTION DES PROJETS
  List<Project> getAllProjects() {
    final String? data = _prefs.getString(_keyProjects);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Project.fromMap(e)).toList();
  }

  Future<void> saveProject(Project project) async {
    final projects = getAllProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  Future<void> deleteProject(String projectId) async {
    deleteTasksByProjectId(projectId);
    final projects = getAllProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  /// GESTION DES TACHES
  List<Task> getAllTasks() {
    final String? data = _prefs.getString(_keyTasks);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    final tasks = getAllTasks();
    tasks.removeWhere((t) => t.projectId == projectId);
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteOneTask(String taskId) async {
    final tasks = getAllTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
}