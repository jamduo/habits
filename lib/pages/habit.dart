import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/dialog_box.dart';
import 'package:habits/pages/util.dart';
import 'package:gql/ast.dart';

DocumentNode getHabit = gql(r'''
  subscription MySubscription($id: Int!) {
    habit: habits_by_pk(id: $id) {
      id
      title
      owner_id
    }
  }
''');

DocumentNode deleteHabit = gql(r'''
  mutation DeleteHabit($id: Int!) {
    habit: delete_habits_by_pk(id: $id) {
      id
      title
    }
  }
''');

class HabitPage extends StatelessWidget {
  const HabitPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // User current_user = Provider.of<AuthProvider>(context).user!;
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    int id = (args?["id"] != null) ? (args?["id"]) : 0;

    return Subscription(
      options: SubscriptionOptions(document: getHabit, variables: { "id": id }),
      builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.hasException) {
          return _layout(
            context,
            "Missing Habit",
            (context) => Text(result.exception.toString()),
            null
          );
        }

        if (result.isLoading) {
          return _layout(
            context,
            "Habit: $id",
            (context) => CenteredList(children: [CircularProgressIndicator(color: Theme.of(context).primaryColor,)]),
            null
          );
        }

        var habit = result.data!['habit'];
        if (habit == null) {
          return _layout(
            context,
            "Habit: $id",
            (context) => Padding(
              padding: EdgeInsets.all(16),
              child: Text("This habit does not exist. (ID: $id)", style: TextStyle(fontSize: 18) ), 
            ),
            null
          );
        }
        
        return _layout(
          context,
          "${habit["title"]}: Habit",
          (context) => Padding(
            padding: EdgeInsets.all(16),
            child: Text(habit.toString(), style: TextStyle(fontSize: 18) ),
          ),
          habit
        );
      },
    );
  }

  Widget _layout(BuildContext context, String title, Widget Function(BuildContext) builder, dynamic habit) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          LogoutIcon(),
        ],
      ),
      body: builder(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (habit == null)
            return; 
          
          String? choice = await showAlertDialog(context, "Delete Confirmation", "Are you sure you want to delete '${habit["title"]}' (ID: ${habit["id"]})", ["Yes", "No"]);
          if (choice == "Yes") {
            final GraphQLClient client = GraphQLProvider.of(context).value;
            client.mutate(MutationOptions(document: deleteHabit, variables: { 'id': habit["id"] }))
              .then((value) => Navigator.pop(context))
              .catchError((err) => print("Unable to delete this habit: " + err.toString()));
          }
        },
        tooltip: 'Test',
        child: Icon(Icons.delete),
      ),
    );
  }
}