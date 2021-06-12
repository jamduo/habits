import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;

  void init() {
    print("Connected to firebase: " + Firebase.app().name);
  }

  Future<User> signIn() async {    
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

      
      notifyListeners();
      return currentUser;
    }

    throw Exception("Login Failed");
  }

  Future<User?> signInBackground() async {
    if (canBackgroundSignIn) {
      final User? user = _auth.currentUser;

      if (user != null) {
        assert(!user.isAnonymous);
        await user.getIdToken();

        
        notifyListeners();
        return _auth.currentUser!;
      }

      throw Exception("Login Failed");
    } else {
      return null;
    }
  }

  User? get user {
    return _auth.currentUser;
  }

  bool get canBackgroundSignIn {
    return _auth.currentUser != null;
  }

  Future<void> signOut() async {  
    await _googleSignIn.signOut();
    await _auth.signOut();
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