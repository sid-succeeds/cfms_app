import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color overlayColor;
  final Color spinnerColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.overlayColor = Colors.black54,
    this.spinnerColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
