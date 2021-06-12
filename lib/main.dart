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

  

  runApp(new App());
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  const App ({ Key? key }): super(key: key);
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
          return _with_auth(context);
        }

        return Loading(message: "Connecting to our servers...",);
      },
    );
  }

  Widget _with_auth(BuildContext context) {
    AuthProvider auth = AuthProvider();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: auth,
        ),
      ],
      child: (auth.user == null) ? _not_signed_in(context, auth) : _with_graphql(context, auth),
    );
  }

  Widget _not_signed_in(BuildContext context, AuthProvider auth) {
    auth.signInBackground();

    return Scaffold(
        appBar: AppBar(
          title: Text("Sign In"),
        ),
        body: CenteredList(children: [
            auth.canBackgroundSignIn ? CircularProgressIndicator(color: Theme.of(context).accentColor) : SizedBox.shrink(),
            Text('You are currently not logged in. Please sign in to continue.',),
            ElevatedButton(onPressed: () => auth.signIn(), child: Text("Sign In")),
          ],
        ),
    );
  }

  Widget _with_graphql(BuildContext context, AuthProvider auth) {
    final Link link = HttpLink(
      'https://hasura.jamduo.org/v1/graphql',
      defaultHeaders: {
        'x-hasura-admin-secret': 'password',
        'X-GoogleUID': auth.user!.uid,
      },
    );

    GraphQLClient client = GraphQLClient( link: link, cache: GraphQLCache() );

    ValueNotifier<GraphQLClient> notifier = ValueNotifier(client);

    client.mutate(MutationOptions(document: gql(upsertUser), variables: { 'google_uid': auth.user!.uid }))
        .then((value) => print("Signed In as User #" + value.data!['user']['id'].toString()))
        .catchError((err) => print("Unable to register sign in: " + err.toString()));

    return GraphQLProvider(
      client: notifier,
      child: HomePage(),
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

const String upsertUser = r'''
  mutation MyMutation($google_uid: String) {
    user: insert_users_one(object: {google_uid: $google_uid, last_seen: "now()"}, on_conflict: {constraint: users_google_uid_key, update_columns: last_seen}) {
      id
      google_uid
      last_seen
    }
  }
''';

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
      GraphQLClient client = GraphQLProvider.of(context).value;
      print(user.uid);
      client.mutate(MutationOptions(document: gql(upsertUser), variables: { 'google_uid': user.uid }))
        .then((value) => print(JsonToString(value.data!['user'])))
        .catchError((err) => print(err));
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
      body: _test(context),
      // CenteredList(
      //   children: [
      //     Text('Weclome $name',), 
      //   ],
      // ),
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
        users {
          id
          google_uid
          last_seen
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
            print(result.exception);
            return Text("Error");
        }

        if (result.isLoading) {
          return Text('Loading');
        }
        List<dynamic> users = result.data!['users'];
        return CenteredList(children: users.map((user) => Text(JsonToString(user))).toList());
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

String JsonToString(Map<String, dynamic> json) {
  return "(" + json.values.map((value) => value.toString()).join(", ") + ")";
}