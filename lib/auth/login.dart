import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'googe_auth.dart';

class Test extends StatelessWidget {
  Test({ Key? key, required User this.user }) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    var name = user.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text("$name's Gaming HQ"),
        actions: [
          // LogoutIcon(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$name is gaming',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 150),
              SizedBox(height: 50),
              _signInButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget _signInButton() {
    return OutlineButton(
      onPressed: () {
        // _auth.signIn().then((user) {{
        //     print(user!.uid);
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) {
        //           return Test(user: user);
        //         },
        //       ),
        //     );
        //   }
        // });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0, width: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}