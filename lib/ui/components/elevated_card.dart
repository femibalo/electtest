import 'package:flutter/material.dart';

class ElevatedCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry? margin;

  const ElevatedCard({Key? key, required this.child, this.margin,this.elevation = 3})
      : super(key: key);

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
