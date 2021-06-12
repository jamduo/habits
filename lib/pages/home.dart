import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/pages/util.dart';
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

DocumentNode queryAllUsers = gql(r'''
  query getUsers { 
    users {
      id
      google_uid
      last_seen
    }
  }
''');

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    User user = auth.user!;
    
    String name = user.displayName ?? "Not Logged In";

    return Scaffold(
      appBar: AppBar(
        title: Text("$name's Habit Home"),
        actions: [
          LogoutIcon(),
        ],
      ),
      body: _build(context),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => null,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }

  Widget _build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: queryAllUsers,
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
      },
    );
  }
}