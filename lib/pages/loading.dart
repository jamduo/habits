import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/firebase_provider.dart';
import 'package:habits/pages/util.dart';
import 'package:provider/provider.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/graphql.dart';

class RequireDatabase extends StatelessWidget {
  late final Widget _child;
  RequireDatabase(Widget child) {
    this._child = child;
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseProvider firebase = Provider.of(context, listen: true);
    final AuthProvider auth = Provider.of(context, listen: true);
    final DatabaseProvider graphql = Provider.of(context, listen: true);

    final isSignInPage = Navigator.of(context).isCurrent("/sign-in");

    if (firebase.app == null)
      return Scaffold(body: Loading(message: "Connecting to our servers..."));

    if (isSignInPage) return _child;

    if (auth.user == null) {
      Future.microtask(() => Navigator.of(context).pushNamedIfNotCurrent("/sign-in"));
      return Scaffold(body: Loading(
        child: ElevatedButton(
          onPressed: () => auth.signIn(),
          child: Text("Sign In")
        ),
        message: "Sign in dummy"),
      );
    }

    if (graphql.client == null) {
      return Scaffold(body: Loading(message: "Something went wrong while contacting the database."));
    }

    return GraphQLProvider(
        client: ValueNotifier(graphql.client!), 
        child: _child,
    );
  }
}

class DataLayer extends StatelessWidget {
  final Widget child;
  const DataLayer({ Key? key, required this.child }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebaseLayer(
      AuthenticationLayer(
        DatabaseLayer(child)
      )
    );
  }
}

class FirebaseLayer extends StatelessWidget {
  late final Widget _child;
  FirebaseLayer(Widget child) {
    this._child =  child;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirebaseProvider(),
      child: _child,
    );
  }
}

class AuthenticationLayer extends StatelessWidget {
  late final Widget _child;
  AuthenticationLayer(Widget child) {
    this._child =  child;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: _child,
    );
  }
}

class DatabaseLayer extends StatelessWidget {
  late final Widget _child;
  DatabaseLayer(Widget child) {
    this._child =  child;
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = Provider.of(context, listen: true);
    return ChangeNotifierProvider(
      create: (_) { 
        var db = DatabaseProvider();
        db.user = auth.user;
        auth.addListener(() { db.user = auth.user; });
        return db;
      },
      child: _child,
    );
  }
}

extension NavigatorStateExtension on NavigatorState {

  void pushNamedIfNotCurrent( String routeName, { Object? arguments } ) {
    if (!isCurrent(routeName)) {
      pushNamed( routeName, arguments: arguments );
    }
  }

  bool isCurrent( String routeName ) {
    bool isCurrent = false;
    popUntil( (route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    } );
    return isCurrent;
  }
}