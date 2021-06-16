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
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;
  GraphQLClient? _client;
  int? userID;

  Future<User> signIn() async {    
    _googleSignIn.signIn().timeout(Duration(seconds: 30));
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    return await _verifySignIn(user);
  }

  Future<User?> signInBackground() async {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signInSilently();
    if (googleSignInAccount == null) return null;
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    return await _verifySignIn(user);
  }

  Future<User> _verifySignIn(User? user) async {
    if (user != null) {
      assert(!user.isAnonymous);
      await user.getIdToken();

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      _setUserId();

      notifyListeners();
      return currentUser;
    }

    throw Exception("Login Failed");
  }

  User? get user {
    return _auth.currentUser;
  }

  // bool get canBackgroundSignIn {
  //   return _auth.currentUser != null;
  // }

  Future<void> signOut() async {  
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }

  void _setUserId() {
    _client?.mutate(MutationOptions(document: queryUpsertUser, variables: { 'google_uid': user?.uid }))
        .then((result) => userID = result.data!['user']['id']);
        // .then((value) => print("Signed In as User #" + value.data!['user']['id'].toString()))
        // .catchError((err) => print("Unable to register sign in: " + err.toString()));
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