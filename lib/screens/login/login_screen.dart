import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import './controllers/controllers.dart';
import '../../constants/style_constants.dart' as StyleConstants;
import 'widgets/login_form.dart';

///
/// Screen to login an authenticate an [Employee}
///
class LoginScreen extends HookWidget {
  ///
  /// Route to this screen
  ///
  static const routeName = "/login";

  ///
  /// Title of This screen
  ///
  static const title = "התחברות";

  @override
  Widget build(BuildContext context) {
    final isTest = useProvider(isTestEnv);
    final viewModel = useProvider(loginViewModel);
    return Scaffold(
      key: viewModel.screenUtils.scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (!isTest) RotatingIcon(),
                if (isTest) IconImage(),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///
/// Class in charge of the animation in the login screen
///
class RotatingIcon extends StatefulHookWidget {
  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  AnimationController animController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      duration: Duration(seconds: 7),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: animController,
      curve: Curves.bounceInOut,
      reverseCurve: Curves.elasticOut,
    );

    animation = Tween<double>(
      begin: 0,
      end: 2 * Math.pi,
    ).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animController.forward();
        }
      });

    animController.forward();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: animation.value,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: IconImage(),
      ),
    );
  }
}

class IconImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ImageProvider logo = AssetImage(StyleConstants.ICON_IMAGE_PATH_JPG);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.height * 0.3,
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      child: Image(
        image: logo,
      ),
    );
  }
}
