// https://medium.com/flutter/flutter-web-navigating-urls-using-named-routes-307e1b1e2050

import 'package:flutter/material.dart';
import 'package:habits/pages/loading.dart';
import 'package:habits/pages/sign_in.dart';
import 'package:habits/pages/util.dart';
import 'package:habits/pages/habit.dart';
import 'package:habits/pages/home.dart';
import 'package:habits/routing/path.dart';

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      HomePage.route,
      (context, match) => RequireDatabase(HomePage()),
    ),
    Path(
      HabitPage.route,
      (context, match) {
        int? id = int.tryParse(match != null ? match : "");
        return RequireDatabase(HabitPage(id: (id != null) ? id : 0));
      },
    ),
    Path(
      SignIn.route,
      (context, match) => RequireDatabase(SignIn())
    )
  ];

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == null) {
      return null;
    }

    for (Path path in paths) {
      final regExpPattern = RegExp(path.pattern);

      if (regExpPattern.hasMatch(settings.name!)) {

        final firstMatch = regExpPattern.firstMatch(settings.name!);
        final match = (firstMatch?.groupCount == 1) ? firstMatch!.group(1) : null;

        print("navigating to ${settings.name}");
        return MaterialPageRoute<void>(
          builder: (context) => path.builder(context, match),
          settings: settings,
        );
      }
    }


    // // If no match was found, we let [WidgetsApp.onUnknownRoute] handle it.
    // return null;
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold( body: ErrorMessage(message: "404 Not found") ),
      settings: settings,
    );
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold( body: ErrorMessage(message: "404 Not found") ),
      settings: settings,
    );
  }

}