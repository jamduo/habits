// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class Auth {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   late Future<FirebaseApp> _firebase;
//   late Future<FirebaseAuth> _auth;

//   Auth() {
//     this._firebase = Firebase.initializeApp();
//     this._auth = _firebase.then((app) => FirebaseAuth.instance);

//     _firebase.then((app) => print("Connected to firebase: " + app.name));
//   }

//   Future<User?> signIn() async {
//     var auth = await _auth;

//     final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
//     final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

//     final AuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleSignInAuthentication.accessToken,
//       idToken: googleSignInAuthentication.idToken,
//     );

//     final UserCredential authResult = await auth.signInWithCredential(credential);
//     final User? user = authResult.user;

//     if (user != null) {
//       assert(!user.isAnonymous);
//       assert(await user.getIdToken() != null);

//       final User? currentUser = auth.currentUser;
//       assert(user.uid == currentUser?.uid);

//       return currentUser;
//     }

//     throw Exception("Login Failed");
//   }

//   Future<User?> currentUser() async {
//     var auth = await _auth;
//     return auth.currentUser;
//   }

//   Future<void> signOut() async {
//     var auth = await _auth;

//     await _googleSignIn.signOut();
//     await auth.signOut();

//     // print("User Signed Out");
//   }

// }

// class LogoutIcon extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(icon: Icon(Icons.logout), onPressed: () async { await Auth().signOut(); Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst); });
//   }
// }

// // Future<void> registerDevice(user) async {
// //   var token = await FirebaseMessaging.instance.getToken();
// //   print('Device Token: ' + token);
// //   await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'device': token});
// // }




// // class LogoutIcon extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return IconButton(icon: Icon(Icons.logout), onPressed: () async { await signOut(); Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst); });
// //   }
// // }