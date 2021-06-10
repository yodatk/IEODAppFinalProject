import 'package:flutter/material.dart';

class NotImplementedPage extends StatelessWidget {
  static const routeName = '/not_implemented_page';
  static const screenTitle = "עמוד זה עוד לא מוכן ";
  static const mainText = "עמוד זה עוד לא מוכן";

  final String title;

  NotImplementedPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              NotImplementedPage.mainText,
            ),
          ],
        ),
      ),
    );
  }
}
