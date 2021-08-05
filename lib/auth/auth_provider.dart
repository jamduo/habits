import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gql/ast.dart';

DocumentNode queryUpsertUser = gql(r'''
  mutation MyMutation($google_uid: String) {
    user: insert_users_one(object: {google_uid: $google_uid, last_seen: "now()"}, on_conflict: {constraint: users_google_uid_key, update_columns: last_seen}) {
      id
      google_uid
      last_seen
    }
  }
''');

class AuthProvider extends ChangeNotifier {
  GoogleSignIn? _googleSignIn;
  FirebaseApp? _firebase;
  FirebaseAuth? _auth;
  GraphQLClient? _client;
  int? userID;

  set firebase(FirebaseApp? app) {
    _firebase = app;
    _googleSignIn = GoogleSignIn();
    _auth = FirebaseAuth.instance;

    notifyListeners();
  }

  bool get initialized {
    return _firebase != null && _googleSignIn != null && _auth != null;
  }

  void mustBeInit() {
    if (!initialized) {
      throw new Exception("Auth Provider not initialized");
    }
  }

  Future<User> signIn() async {   
    mustBeInit();
    var googleSignIn = _googleSignIn!;
    var auth = _auth!;

    googleSignIn.signIn().timeout(Duration(seconds: 30));
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await auth.signInWithCredential(credential);
    final User? user = authResult.user;

    return await _verifySignIn(user);
  }

  Future<User?> signInBackground() async {
    mustBeInit();
    var googleSignIn = _googleSignIn!;
    var auth = _auth!;

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signInSilently();
    if (googleSignInAccount == null) return null;
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await auth.signInWithCredential(credential);
    final User? user = authResult.user;

    return await _verifySignIn(user);
  }

  Future<User> _verifySignIn(User? user) async {
    mustBeInit();
    var auth = _auth!;

    if (user != null) {
      assert(!user.isAnonymous);
      await user.getIdToken();

      final User currentUser = auth.currentUser!;
      assert(user.uid == currentUser.uid);

      _setUserId();

      notifyListeners();
      return currentUser;
    }

    throw Exception("Login Failed");
  }

  User? get user {
    return _auth?.currentUser;
  }

  // bool get canBackgroundSignIn {
  //   return _auth.currentUser != null;
  // }

  Future<void> signOut() async {  mustBeInit();
    var googleSignIn = _googleSignIn!;
    var auth = _auth!;

    await googleSignIn.signOut();
    await auth.signOut();
    notifyListeners();
  }

  void _setUserId() {
    _client?.mutate(MutationOptions(document: queryUpsertUser, variables: { 'google_uid': user?.uid }))
        .then((result) => result.data!['user'])
        .then((user) { userID = user['id']; print("Signed In as User #" + userID.toString()); })
        .catchError((err) { print("Unable to register sign in: " + err.toString()); });
  }

  set client(GraphQLClient client) {
    _client = client;
    if (userID == null) {
      _setUserId();
    }
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