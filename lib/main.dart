// import 'package:habits/auth/login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/graphql.dart';
import 'package:habits/pages/habit.dart';
import 'package:habits/pages/home.dart';
import 'package:habits/pages/util.dart';
import 'package:habits/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'notifications/notification_service.dart' if (dart.library.html) 'notifications/notification_service_web.dart';

// import 'notification_service.dart';
// import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) {
  //   // Android-specific code
  await NotificationService().init();
  // }
  runApp(new App());
}

class App extends StatefulWidget {
  const App ({ Key? key }): super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits',
      themeMode: ThemeMode.system,
      theme: makeLightTheme(),
      darkTheme: makeDarkTheme(),
      initialRoute: "/",
      routes: {
        "/": (BuildContext content) => _withFirebaseApp(context),
      }
    );
  }

  Widget _withFirebaseApp(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return _Error(snapshot.error.toString());
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return _withAuth(context);
        }

        return Loading(message: "Connecting to our servers...",);
      },
    );
  }

  Widget _withAuth(BuildContext context) {   
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
      ],
      child: RequireAuthenitcation(
        child: _navigator(context)
        // HomePage()
      ),
    );
  }

  Widget _navigator(BuildContext context) {
    return Navigator(
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case "/":
            builder = (BuildContext content) => HomePage();
            break;
          case "/habit":
            builder = (BuildContext content) => HabitPage();
            break;

          default:
            throw Exception('Invalid route: ${settings.name}');
        }

        return MaterialPageRoute<void>(builder: builder, settings: settings);
       },

    );
  }

  // ignore: non_constant_identifier_names
  Widget _Error(String s) {
    return CenteredList(
      children: [
        WithPadding(child: Text(s)),
      ],
    );
  }  
}

class RequireAuthenitcation extends StatelessWidget {
  final Widget? child;
  const RequireAuthenitcation({ Key? key, this.child }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: true);
    return (auth.user == null) ? _notSignedIn(context, auth) : _withGraphQL(context, auth);
  }

  Widget _notSignedIn(BuildContext context, AuthProvider auth) {
    auth.signInBackground();

    return Scaffold(
        appBar: AppBar(
          title: Text("Sign In"),
        ),
        body: CenteredList(children: [
            // auth.canBackgroundSignIn ? CircularProgressIndicator(color: Theme.of(context).accentColor) : SizedBox.shrink(),
            Text('You are currently not logged in. Please sign in to continue.',),
            ElevatedButton(onPressed: () => auth.signIn(), child: Text("Sign In")),
          ],
        ),
    );
  }

  Widget _withGraphQL(BuildContext context, AuthProvider auth) {
    ValueNotifier<GraphQLClient> client = GraphQL.initailizeClient(auth.user!);
    auth.client = client.value;
    
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}