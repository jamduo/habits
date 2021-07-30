import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/pages/util.dart';
import 'package:provider/provider.dart';
import 'package:gql/ast.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habits/notifications/notification_service.dart' if (dart.library.html) 'package:habits/notifications/notification_service_web.dart';

DocumentNode queryAddHabit = gql(r'''
  mutation addHabit($owner_id: Int, $title: String) {
    habit: insert_habits_one(object: {owner_id: $owner_id, title: $title}) {
      id
      owner_id
      title
    }
  }
''');

DocumentNode subscriptionUsers = gql(r'''
  subscription {
    users {
      id
      last_seen
    }
  }
''');

DocumentNode subscriptionHabits = gql(r'''
  subscription {
    habits {
      id
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () async { await NotificationService().sendNotification(id: Random().nextInt(1<<31)); },
              tooltip: 'Add Notification',
              backgroundColor: Color.fromRGBO(0, 200, 0, 0.8),
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () async { await NotificationService().cancelAllNotifications(); },
              tooltip: 'Remove All Notifications',
              backgroundColor: Color.fromRGBO(0, 200, 0, 0.8),
              child: Icon(Icons.remove),
            ),
            FloatingActionButton(
              onPressed: () async {
                final GraphQLClient client = GraphQLProvider.of(context).value;
                client.mutate(MutationOptions(document: queryAddHabit, variables: { 'owner_id': auth.userID, 'title': "testy" }))
                  .then((value) => print("Added habit #" + value.data!['habit']['id'].toString() + " " + value.data!['habit']['title']))
                  .catchError((err) => print("Unable to add a habit: " + err.toString()));
                // print(await user.getIdToken());
                // client.subscribe(SubscriptionOptions(document: subscriptionUsers)).listen((event) { print(event.data!["users"]); });
                // const AndroidNotificationDetails androidPlatformChannelSpecifics = 
                //   AndroidNotificationDetails(
                //       "channelId", 
                //       "channelName",
                //       "channelDescription",
                //       importance: Importance.defaultImportance,
                //       priority: Priority.defaultPriority
                //   );
                // const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
                // await NotificationService().flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title', 'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics, androidAllowWhileIdle: true);
                // await NotificationService().flutterLocalNotificationsPlugin.show(0, "title", "body", platformChannelSpecifics, payload: "data");
              },
              tooltip: 'Add Habit',
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    // User current_user = Provider.of<AuthProvider>(context).user!;
    return Subscription(
      options: SubscriptionOptions(document: subscriptionHabits),
      // Just like in apollo refetch() could be used to manually trigger a refetch
      // while fetchMore() can be used for pagination purpose
      builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.hasException) {
            return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return CenteredList(children: [CircularProgressIndicator(color: Theme.of(context).primaryColor,)]);
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
                    // ignore: dead_code
                    true ? Icons.favorite : Icons.favorite_border,
                    // ignore: dead_code
                    color: true ? Colors.red : null,
                  ),
                  onPressed: null,
                ),
                onTap: () {
                  Navigator.pushNamed(context, "/habit", arguments: { "id": habit['id'] }); },
              ),
            );
          }
        );
      },
    );
  }
}