import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String message;
  final double size;
  final Widget? child;
  const Loading({ Key? key, this.child, required this.message, this.size = 50 }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
        WithPadding(child: Container(height: size, width: size, child: CircularProgressIndicator(strokeWidth: size * 0.1,))), //color: Theme.of(context).accentColor
        WithPadding(child: Text(message)),
    ];
    if (child != null)
      children.add(child!);
      
    return CenteredList(
      children: children,
    );
  }
}

String jsonToString(Map<String, dynamic> json) {
  return "(" + json.values.map((value) => value.toString()).join(", ") + ")";
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

// ignore: must_be_immutable
class ErrorMessage extends StatelessWidget {
  String message;
  ErrorMessage({ Key? key, required this.message }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CenteredList(
      children: [
        WithPadding(child: Text(message)),
      ],
    );
  }
}