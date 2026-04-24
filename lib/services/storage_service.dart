import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';
import '../models/project.dart';
import '../models/task.dart';

/// Pattern Singleton:
/// Pour avoir une seule instance
/* Sharedpreference c'est juste une bibliotheque qui permet de communique avec le disque dur du telephone */
/* La classe StorageService c'est pas SharedPreference car on pouvais utiliser autre chose,
d'apres ce que j'ai compris,  on pouvait utiliser firebase/supabase, hive, isar ou
meme pour le hashage de mot de passe avec Flutter secure storage*/
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
  ///
  /*
  Quant on fait late, on promet qu'on initialise une
  variable avant de l'utiliser.
  _prefs fait le lien entre nos variables et un fichier (XML/Plist).
  C'est le meme concepte qu'en java ou c# ou l'on
  a un objet qui nous permet de faire la liaison
  entre nos variables de RAM (em/context) et la BD */
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  /* comme lire ou ecrire sur le disque dur prend du temps
  On fait appel au trio Future, async et await
  Future pour dire que le resultat c'est pas maintenant
  Async pour annoncer que c'est une operation asynchrone
  await pour marque une pause de l'execution de la
  fonction et eviter que l'ecran plante au scroll*/
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  //Cles de Stockage
  static const String _keyOnboardingConmplete = 'onboarding_complete';


  // void _checkInitialized() {
  //   if (!_initialized) throw Exception("StorageService non initialisé. Appelez init() d'abord.");
  // }

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
      debugPrint("Erreur : $e");
      return [];
    }
  }

  /* Sachant sharedPreference ne connait pas
  les objet, il ne connait que les type primitf
  nous lorsqu'on va ecrire ou lire des donnees
  on va faire ce qu'on appel la serialisation ou
  la deserialisation.
  Pour la serialisation on transforme l'objet en String avec jsonEncode
  ou on fait le contraire avec jsonDecode*/
  Future<void> saveUser(User user) async {
    try{
      final List<User> users = getAllUsers();
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user;
      } else {
        users.add(user);
      }
      final String encodedData = jsonEncode(users.map((u) => u.toMap()).toList());
      await _prefs.setString(_keyUsers, encodedData);
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }

  /// GESTION DE LA SESSION
  Future<void> saveCurrentUser(User user) async {
    try{
      final String userJson = jsonEncode(user.toMap());
      await _prefs.setString(_keyCurrentUser, userJson);
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }

  User? getCurrentUser() {
    try{
      final String? userJson = _prefs.getString(_keyCurrentUser);
      if (userJson == null) return null;
      return User.fromMap(jsonDecode(userJson));
    }catch(e){
      debugPrint("Erreur : $e");
      return null;
    }
  }

  Future<void> removeCurrentUser() async {
    try{
      await _prefs.remove(_keyCurrentUser);
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }

  /// GESTION DES PROJETS
  List<Project> getAllProjects() {
    try{
      final String? data = _prefs.getString(_keyProjects);
      if (data == null) return [];
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Project.fromMap(e)).toList();
    }catch(e){
      debugPrint("Erreur : $e");
      return [];
    }
  }

  Future<void> saveProject(Project project) async {
    try{
      final projects = getAllProjects();
      final index = projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        projects[index] = project;
      } else {
        projects.add(project);
      }
      await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }

  Future<void> deleteProject(String projectId) async {
   try{
     deleteTasksByProjectId(projectId);
     final projects = getAllProjects();
     projects.removeWhere((p) => p.id == projectId);
     await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
   }catch(e){
     debugPrint("Erreur : $e");
   }
  }

  /// GESTION DES TACHES
  List<Task> getAllTasks() {
    try{
      final String? data = _prefs.getString(_keyTasks);
      if (data == null) return [];
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Task.fromMap(e)).toList();
    }catch(e){
      debugPrint("Erreur : $e");
      return [];
    }
  }

  Future<void> saveTask(Task task) async {
    try{
      final tasks = getAllTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
      } else {
        tasks.add(task);
      }
      await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    try{
      final tasks = getAllTasks();
      tasks.removeWhere((t) => t.projectId == projectId);
      await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }

  Future<void> deleteOneTask(String taskId) async {
    try{
      final tasks = getAllTasks();
      tasks.removeWhere((t) => t.id == taskId);
      await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
    }catch(e){
      debugPrint("Erreur : $e");
    }
  }
}