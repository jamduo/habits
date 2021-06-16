import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/pages/util.dart';
import 'package:provider/provider.dart';
import 'package:gql/ast.dart';

DocumentNode queryAllHabits = gql(r'''
  query allHabits {
    habits {
      id
      title
    }
  }
''');

DocumentNode queryAddHabit = gql(r'''
  mutation addHabit($owner_id: Int, $title: String) {
    habit: insert_habits_one(object: {owner_id: $owner_id, title: $title}) {
      id
      owner_id
      title
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final GraphQLClient client = GraphQLProvider.of(context).value;
          client.mutate(MutationOptions(document: queryAddHabit, variables: { 'owner_id': auth.user_id, 'title': "testy" }))
            .then((value) => print("Added habit #" + value.data!['habit']['id'].toString() + " " + value.data!['habit']['title']))
            .catchError((err) => print("Unable to add a habit: " + err.toString()));
        },
        tooltip: 'Add Habit',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _build(BuildContext context) {
    User current_user = Provider.of<AuthProvider>(context).user!;
    return Query(
      options: QueryOptions(
        document: queryAllHabits,
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

        List<dynamic> habits = result.data!['habits'];
        if (habits.length == 0) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Text("Add a habit and it will show up here...", style: TextStyle(fontSize: 18) ), 
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          itemCount: habits.length * 2,
          itemBuilder: (context, i) {
            if (i.isOdd) return Divider();
        
            final index = i ~/ 2;
            final habit = habits[index];
            return Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: ListTile(
                title: Text(
                  habit['title'].toString(),
                  style: TextStyle(fontSize: 18.0),
                ),
                trailing: IconButton(
                  icon: Icon(
                    true ? Icons.favorite : Icons.favorite_border,
                    color: true ? Colors.red : null,
                  ),
                  onPressed: null,
                ),
                // onTap: () { },
              ),
            );
          }
        );
      },
    );
  }
}