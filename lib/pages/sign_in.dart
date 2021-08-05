import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/graphql.dart';
import 'package:habits/pages/loading.dart';
import 'package:habits/pages/util.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  static final String route = r'^/sign-in$';

  const SignIn({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: true);
    final returnToPage = (user) { if (user != null) { Navigator.of(context).popUntil((route) => route.settings.name != "/sign-in"); } };

    if (auth.user != null)
      returnToPage(auth.user);
    else 
      auth.signInBackground().then(returnToPage);

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: CenteredList(children: [
          // auth.canBackgroundSignIn ? CircularProgressIndicator(color: Theme.of(context).accentColor) : SizedBox.shrink(),
          Text('You are currently not logged in. Please sign in to continue.',),
          ElevatedButton(onPressed: () => auth.signIn().then(returnToPage), child: Text("Sign In")),
        ],
      ),
    );
  }
}
