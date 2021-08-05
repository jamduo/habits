import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:habits/auth/auth_provider.dart';
import 'package:habits/dialog_box.dart';
import 'package:habits/pages/util.dart';
import 'package:gql/ast.dart';

DocumentNode getHabit = gql(r'''
  subscription getHabit($id: Int!) {
    habit: habits_by_pk(id: $id) {
      id
      owner_id
      title
      month
      day
      hour
      minute
      second
      day_of_week
      week_of_month
      week_of_year
      created_at
      updated_at
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


class Habit {
  dynamic raw;
  late int? id;
  late String title;
  int? month;
  int? day;
  int? hour;
  int? minute;
  int? second;
  // ignore: non_constant_identifier_names
  int? day_of_week;
  // ignore: non_constant_identifier_names
  int? week_of_month;
  // ignore: non_constant_identifier_names
  int? week_of_year;


  // Habit({this.title, this.isSubscribed = true, this.schedule, });

  Habit.fromJson(dynamic habit) {
    if (habit == null) throw new Exception("Cannot create a habit model from null.");
    this.raw = habit;
    this.id = _Int("id")!;
    this.title = _String("title")!;
    this.month = _Int("month");
    this.day = _Int("day");
    this.hour = _Int("hour");
    this.minute = _Int("minute");
    this.second = _Int("second");
    this.day_of_week = _Int("day_of_week");
    this.week_of_month = _Int("week_of_month");
    this.week_of_year = _Int("week_of_year");
  }

  dynamic _getRequiredProperty(String key) {
    return this.raw.containsKey(key) ? this.raw[key] : throw new Exception("Cannot create a habit model without the '$key' attribute.");
  }
  // ignore: non_constant_identifier_names
  String? _String(String key) {
    return _getRequiredProperty(key) as String?;
  }
  // ignore: non_constant_identifier_names
  int? _Int(String key) {
    return _getRequiredProperty(key) as int?;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "month": month,
    "day": day,
    "hour": hour,
    "minute": minute,
    "second": second,
    "day_of_week": day_of_week,
    "week_of_month": week_of_month,
    "week_of_year": week_of_year,
  };

  @override
  String toString() {
    return jsonEncode(this);
  }

  // Map<String, dynamic> toSerial() {
  //   return {
  //     'name': this.name,
  //     'schedule': this.schedule,
  //     'body': this.body,
  //     'image': this.image,
  //     'isSubscribed': this.isSubscribed,
  //   };
  // }

  static Future<List<Habit>> getAll(GraphQLClient client) async {
    final query = gql(r'''
      query {
        habits {
          id
          owner_id
          title
          month
          day
          hour
          minute
          second
          day_of_week
          week_of_month
          week_of_year
          created_at
          updated_at
        }
      }
    ''');
    return client.query(QueryOptions(document: query))
      .then((result) => result.data!["habits"]!)
      .then((habits) => habits.map<Habit>((habit) => Habit.fromJson(habit)).toList());
  }

  static Future<Habit?> get(GraphQLClient client, int id) async {
    final query = gql(r'''
      query getHabit($id: Int!) {
        habit: habits_by_pk(id: $id) {
          id
          owner_id
          title
          month
          day
          hour
          minute
          second
          day_of_week
          week_of_month
          week_of_year
          created_at
          updated_at
        }
      }
    ''');
    return client.query(QueryOptions(document: query, variables: { "id": id }))
      .then((result) => result.data!["habit"]!)
      .then((habit) => Habit.fromJson(habit));
  }

  Future<Habit?> update(GraphQLClient client) async {
    final query = gql(r'''
      mutation updateHabit($id: Int!, $title: String, $month: Int, $day: Int, $hour: Int, $minute: Int, $second: Int, $day_of_week: Int, $week_of_month: Int, $week_of_year: Int) {
        habit: update_habits_by_pk(
          pk_columns: { id: $id },
          _set: {
            title: $title,
            month: $month,
            day: $day,
            hour: $hour,
            minute: $minute,
            second: $second,
            day_of_week: $day_of_week,
            week_of_month: $week_of_month,
            week_of_year: $week_of_year
          }
        ) {
          id
          owner_id
          title
          month
          day
          hour
          minute
          second
          day_of_week
          week_of_month
          week_of_year
          created_at
          updated_at
        }
      }
    ''');
    return client.mutate(MutationOptions(document: query, variables: toJson() ))
      .then((result) => result.data!["habit"]!)
      .then((habit) => Habit.fromJson(habit));
  }

  // static Future<Habit> get(String documentId) async {
  //   var job = Habit.fromSerial(await _userHabits().doc(documentId).get());
  //   return job;
  // }

  // Future<DocumentSnapshot> set() async {
  //   // var userHabits = await _userHabits();
  //   if (this.id == null) {
  //     return (await this.add()).get();
  //   } else {
  //     await this.update();
  //     return _userHabits().doc(this.id).get();
  //   }
  // }

  // Future<DocumentReference> add() async {
  //     return _userHabits().add(this.toSerial());
  // }

  // Future<void> update() async {
  //   return _userHabits().doc(this.id).set(this.toSerial());
  // }

  // Future<void> delete() async {
  //   return _userHabits().doc(this.id).delete();
  // }
}

class HabitPage extends StatelessWidget {
  static final String route = r'^/habit/(\d+)$';
  final int id;

  const HabitPage({ Key? key, required this.id }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // User current_user = Provider.of<AuthProvider>(context).user!;
    // dynamic args = ModalRoute.of(context)!.settings.arguments;
    // int id = (args?["id"] != null) ? (args?["id"]) : 0;

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

        var a = result.data?['habit'];
        if (a == null) {
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
        
        final habit = Habit.fromJson(a);
        return _layout(
          context,
          "${habit.title}: Habit",
          (context) => Padding(
            padding: EdgeInsets.all(16),
            child: _form(context, habit),
            // child: Text(habit.raw.toString(), style: TextStyle(fontSize: 18) ),
          ),
          habit
        );
      },
    );
  }
  
  Widget _form(BuildContext context, Habit habit) {
    final formKey = GlobalKey<FormState>();
    return Form(
      key:formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextFormField(
              onSaved: (val) {  },
              enabled: false,
              decoration: const InputDecoration(
                hintText: 'Your habit title',
                labelText: 'ID',
              ),
              initialValue: habit.id.toString(),
            ),
            TextFormField(
              onSaved: (val) { habit.title = (val != null) ? val : habit.title; },
              decoration: const InputDecoration(
                hintText: 'Your habit title',
                labelText: 'Title',
              ),
              initialValue: habit.title,
            ),
            _timeFormField("Month",  "month",  habit.month == null ? "" : habit.month,   (val) { habit.month = (val != null) ? int.tryParse(val) : habit.month; }),
            _timeFormField("Day",    "day",    habit.day  == null ? "" : habit.day,      (val) { habit.day = (val != null) ? int.tryParse(val) : habit.day; }),
            _timeFormField("Hour",   "hour",   habit.hour  == null ? "" : habit.hour,    (val) { habit.hour = (val != null) ? int.tryParse(val) : habit.hour; }),
            _timeFormField("Minute", "minute", habit.minute == null ? "" : habit.minute, (val) { habit.minute = (val != null) ? int.tryParse(val) : habit.minute; }),
            _timeFormField("Second", "second", habit.second == null ? "" : habit.second, (val) { habit.second = (val != null) ? int.tryParse(val) : habit.second; }),
            _timeFormField("Day of the Week", "day_of_week", habit.day_of_week == null ? "" : habit.day_of_week, (val) { habit.day_of_week = (val != null) ? int.tryParse(val) : habit.day_of_week; }),
            _timeFormField("Week of the Month", "week_of_month", habit.week_of_month == null ? "" : habit.week_of_month, (val) { habit.week_of_month = (val != null) ? int.tryParse(val) : habit.week_of_month; }),
            _timeFormField("Week of the Year", "week_of_year", habit.week_of_year == null ? "" : habit.week_of_year, (val) { habit.week_of_year = (val != null) ? int.tryParse(val) : habit.week_of_year; }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _submit(context, formKey, habit),
                  child: Text('Update'),
                ),
              ],
            ),
          ]
        ),
      )
    );
  }

  Widget _timeFormField(String label, String accessor, dynamic initialValue, void Function(String?) onSave) {
    return TextFormField(
      onSaved: onSave,
      decoration: InputDecoration(
        hintText: '$label to notify on (if required)',
        labelText: '$label',
        focusColor: Colors.deepPurpleAccent
      ),
      initialValue: initialValue.toString(),
    );
  }

  void _submit(BuildContext context, GlobalKey<FormState> formKey, Habit habit) async {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();

        final GraphQLClient client = GraphQLProvider.of(context).value;
        habit.update(client).then((result) => print(result)).catchError((error) => print(error));
        // var newHabit = await widget.job.set();
        // setState(() {
        //   widget.job = Habit.fromSerial(newHabit);
        // });
        // Navigator.of(context).pop(widget.job);
      }
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