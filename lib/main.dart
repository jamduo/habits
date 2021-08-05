import 'package:habits/pages/loading.dart';
import 'package:habits/routing/configuration.dart';
import 'package:habits/theme.dart';
import 'package:flutter/material.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureApp();
  runApp(new App());
}

class App extends StatefulWidget {
  const App ({ Key? key }): super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return DataLayer(
      child: MaterialApp(
        title: 'Habits',
        themeMode: ThemeMode.system,
        theme: makeLightTheme(),
        darkTheme: makeDarkTheme(),
        initialRoute: "/",
        onGenerateRoute: RouteConfiguration.onGenerateRoute,
        // onUnknownRoute: RouteConfiguration.onUnknownRoute,
      ),
    );
  }
}