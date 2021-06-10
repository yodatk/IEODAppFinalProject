import 'package:flutter/material.dart';

///
/// Centered Loading [Widget]
///
class LoadingCircularWidget extends StatelessWidget {
  const LoadingCircularWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
