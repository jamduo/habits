import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseProvider extends ChangeNotifier {
  late final Future<FirebaseApp> _initializer;
  FirebaseApp? app;

  FirebaseProvider() {
    this._initializer = Firebase.initializeApp();
    this._initializer.then((value) { 
      this.app = value;
      notifyListeners();
    });
  }
}