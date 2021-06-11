// import 'package:habits/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Link link = HttpLink('http://10.0.2.2:4000/graphql');

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    ),
  );

  runApp(new App(client: client));
}

class App extends StatefulWidget {
  final ValueNotifier<GraphQLClient> client;
  // Create the initialization Future outside of `build`:
  const App ({ Key? key, required this.client }): super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits',
      themeMode: ThemeMode.system,
      theme: makeLightTheme(),
      darkTheme: makeDarkTheme(),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: _with_firebase_app(context),
    );
  }

  Widget _with_firebase_app(BuildContext context) {
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
          return _with_graphql();
        }

        return Loading(message: "Waiting for authentication server...",);
      },
    );
  }

  Widget _with_graphql() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
      ],
      child: 
        GraphQLProvider(
        client: widget.client,
        child: HomePage(),
      ),
    );
  }


  Widget _Error(String s) {
    return CenteredList(
      children: [
        WithPadding(child: Text(s)),
      ],
    );
  }  
}

class Loading extends StatelessWidget {
  final String message;
  const Loading({ Key? key, required this.message }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CenteredList(
      children: [
        WithPadding(child: CircularProgressIndicator()), //color: Theme.of(context).accentColor
        WithPadding(child: Text(message)),
      ],
    );
  }
}

class CenteredList extends StatelessWidget {
  final List<Widget> children;
  final bool shouldPad;
  const CenteredList({ Key? key, required this.children, this.shouldPad = true }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var paddedChildren = shouldPad ? children.map((item) { return (WithPadding(child: item)); } ).toList() : children;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: paddedChildren,
      ),
    );
  }
}

class WithPadding extends StatelessWidget {
  final double padding;
  final Widget child;
  const WithPadding({ Key? key, this.padding = 8.0, required this.child }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User? user = auth.user;
    if (user == null) {
      auth.signInBackground();

      return Scaffold(
        appBar: AppBar(
          title: Text("Unknown's Training Home"),
        ),
        body: CenteredList(children: [
            auth.canBackgroundSignIn ? CircularProgressIndicator(color: Theme.of(context).accentColor) : SizedBox.shrink(),
            Text('You are currently not logged in. Please sign in to continue.',),
            ElevatedButton(onPressed: () => auth.signIn(), child: Text("Sign In")),
          ],
        ),
      );
    } else  {
      // return _test(context);
      return _build(context, user);
    }
  }

  Widget _build(BuildContext context, User user) {
    var name = user.displayName ?? "Not Logged In";
    return Scaffold(
      appBar: AppBar(
        title: Text("$name's Training Home"),
        actions: [
          LogoutIcon(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Weclome $name',),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => null,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }

  Widget _test(BuildContext context) {
    String queryAllUsers = """
      query getUsers { 
        users: allUsers {
          id,
          google_uid
        }
      }
    """;

    return Query(
      options: QueryOptions(
        document: gql(queryAllUsers), // this is the query string you just created
        // variables: {
        //   'nRepositories': 50,
        // },
        pollInterval: Duration(seconds: 10),
      ),
      // Just like in apollo refetch() could be used to manually trigger a refetch
      // while fetchMore() can be used for pagination purpose
      builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.hasException) {
            return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Text('Loading');
        }

        return Text("Loaded");
        // it can be either Map or List
        // List repositories = result.data['viewer']['repositories']['nodes'];

        // return ListView.builder(
        //   itemCount: repositories.length,
        //   itemBuilder: (context, index) {
        //     final repository = repositories[index];

        //     return Text(repository['name']);
        // });
      },
    );
  }
}