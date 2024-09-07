import 'package:flutter/material.dart';

class ElevatedCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry? margin;

  const ElevatedCard(
      {super.key, required this.child, this.margin, this.elevation = 3});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      margin: margin,
      elevation: elevation,
      shadowColor: Colors.grey,
      child: child,
    );
  }
}
