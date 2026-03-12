import 'package:flutter/material.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final Uuid _uuid = const Uuid();

  // Propriétés privées
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters publics
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;  // true si _currentUser != null
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Méthodes à implémenter
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = _storage.getCurrentUser();
    } catch (e) {
      _error = "Erreur de chargement de session";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }  // Charge l'utilisateur depuis le stockage

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<User> allUsers = _storage.getAllUsers();
      if (allUsers.any((u) => u.email == email)) {
        _error = "Cet email est deja utilise par un autre compte.";
        return false;
      }

      final newUser = User(
        id: _uuid.v4(),
        name: name,
        email: email,
        password: password,
      );

      await _storage.saveUser(newUser);
      await _storage.saveCurrentUser(newUser);

      _currentUser = newUser;
      return true;
    } catch (e, stacktrace) {
      print("ERREUR TECHNIQUE : $e");
      print("STACKTRACE : $stacktrace");
      _error = "Une erreur est survenue lors de l'inscription.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } // Inscription

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<User> allUsers = _storage.getAllUsers();

      final user = allUsers.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception("Identifiants incorrects"),
      );

      await _storage.saveCurrentUser(user);
      _currentUser = user;
      return true;
    }catch (e, stacktrace) {
      print("ERREUR TECHNIQUE : $e");
      print("STACKTRACE : $stacktrace");
      _error = "Email ou mot de passe incorrect.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } // Connexion

  Future<void> logout() async {
    await _storage.removeCurrentUser();
    _currentUser = null;
    notifyListeners();
  } // Deconnexion

  Future<void> updateProfile({String? name, String? email, String? avatar}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email,
        avatar: avatar,
      );

      await _storage.saveUser(updatedUser);
      await _storage.saveCurrentUser(updatedUser);

      _currentUser = updatedUser;
    } catch (e, stacktrace) {
      print("ERREUR TECHNIQUE : $e");
      print("STACKTRACE : $stacktrace");
      _error = "Erreur lors de la mis à jour du profil.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  } // Efface le message d'erreur

}