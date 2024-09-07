import 'package:flutter/material.dart';
import 'package:invoice_management/ui/components/simpleElevatedButton.dart';

class LoadingElevatedButton extends StatefulWidget {
  final String text;
  final Function onPressed;
  final bool expanded;
  final bool showLoading;

  const LoadingElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.expanded,
    required this.showLoading,
  });

  @override
  State<LoadingElevatedButton> createState() => _LoadingElevatedButtonState();
}

class _LoadingElevatedButtonState extends State<LoadingElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
        child: widget.showLoading
            ? Container(
                alignment: Alignment.center,
                height: 36,
                width: 36,
                child: FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: SimpleElevatedButton(
                    text: widget.text,
                    onPressed: () {
                      widget.onPressed();
                    },
                    expanded: widget.expanded),
              ));
  }
}
