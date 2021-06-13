import 'package:flutter/material.dart';

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

String JsonToString(Map<String, dynamic> json) {
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