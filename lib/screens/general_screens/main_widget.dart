import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../logger.dart' as Logger;
import '../../logic/EmployeeHandler.dart';
import '../login/login_screen.dart';
import '../projects_menu_screens/choose_project_menu/check_for_existing_project_widget.dart';
import 'splash_screen_after_login.dart';

final isConnectedProvider =
    StreamProvider.autoDispose((ref) => EmployeeHandler().isConnected());

class MainWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final uid = useProvider(isConnectedProvider);
    return uid.when(
      data: (user) => user == null ? LoginScreen() : CheckForExistingProject(),
      loading: () => MySplashScreen(),
      error: (err, stack) {
        if (err.toString().contains("permission-denied")) {
          Logger.warning(
              "need to check 'permission-denied' exception in 'MainWidget' here...");
        } else {
          Logger.criticalList([
            "unexpected error:",
            err.toString(),
            stack.toString(),
            "error type:${err.runtimeType.toString()}"
          ]);
        }
        return LoginScreen();
      },
    );
  }
}
