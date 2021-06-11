import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isReady = false;
  late FirebaseApp _firebase;
  late FirebaseAuth _auth;
  User? _user = null;

  Future<void> init() {
    return Firebase.initializeApp().then((app) {
      _firebase = app;
      _auth = FirebaseAuth.instance;
      _isReady = true;

      print("Connected to firebase: " + app.name);
    });
  }

  Future<User> signIn() async {
    if (!_isReady) {
      await init();
    }
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      await user.getIdToken();

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      _user = user;
      
      notifyListeners();
      return currentUser;
    }

    throw Exception("Login Failed");
  }

  Future<User?> signInBackground() async {
    if (!_isReady) {
      await init();
    }

    if (canBackgroundSignIn) {
      final User? user = _auth.currentUser;

      if (user != null) {
        assert(!user.isAnonymous);
        await user.getIdToken();

        _user = user;
        
        notifyListeners();
        return _auth.currentUser!;
      }

      throw Exception("Login Failed");
    } else {
      return null;
    }
  }

  User? get user {
    if (!_isReady) {
      return null;
    }

    return _auth.currentUser;
  }

  bool get canBackgroundSignIn {
    return _isReady && _auth.currentUser != null;
  }

  Future<void> signOut() async {
    if (!_isReady) {
      await init();
    }
    
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

}

class LogoutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    
    if (provider.user != null) {
      return IconButton(icon: Icon(Icons.logout), onPressed: () async { await provider.signOut(); });
    } else {
      return SizedBox.shrink();
    }
  }
}