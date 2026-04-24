import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sunu_task/services/storage_service.dart';
/*
Sachant que c'est dans les providers
que l'on gere la logique metier de notre
app et que les widgets vont se servir
des providers pour savoir quant est ce qu'ils
doivent se reconstruire, a chaque fois
que les donnees changes au niveau des providers,
ces derniers doivent le communiquer au widgets.
Pour ce faire la classe ChangeNotifier joue
le role d'alarme et notifiListener le button
de l'alarme.
*/
  class AppProvider extends ChangeNotifier {
    final StorageService _storage = StorageService.instance;

    // Propriétés privées
    bool _isOnboardingComplete = false;
    bool _isInitialized = false;
    bool _isLoading = false;

  // Getters publics
    bool get isOnboardingComplete => _isOnboardingComplete;
    bool get isInitialized => _isInitialized;
    bool get isLoading => _isLoading;

    Future<void> init() async {
      _isLoading = true;
      notifyListeners();

      try {
        await _storage.init();
        _isOnboardingComplete = _storage.isOnboardingComplete;
        _isInitialized = true;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } // Charge l'état depuis StorageService

    Future<void> completeOnboarding() async {
      _isOnboardingComplete = true;
      await _storage.setOnboardingComplete(_isOnboardingComplete);
      notifyListeners();
    } // Marque l'onboarding comme terminé

    Future<void> resetOnboarding() async {
      _isOnboardingComplete = false;
      await _storage.setOnboardingComplete(false);
      notifyListeners();
    }    // Réinitialise l'onboarding
  }