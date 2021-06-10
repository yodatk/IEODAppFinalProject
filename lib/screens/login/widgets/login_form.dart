import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/constants.dart' as Constants;
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Login form to show in the Login Screen
///
class LoginForm extends HookWidget {
  ///
  /// Text to show on the submit button in the Login form
  ///
  static const SUBMIT_TEXT = "התחבר";

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(loginViewModel);
    final node = FocusScope.of(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FormBuilder(
                key: viewModel.formKey,
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                      key: Key(Keys.LOGIN_EMAIL),
                      name: Constants.EMPLOYEE_EMAIL,
                      decoration: InputDecoration(labelText: " אימייל "),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.email(context,
                            errorText: "האימייל שהוכנס איננו תקין"),
                        FormBuilderValidators.required(
                          context,
                          errorText: 'שדה זה הינו חובה להתחברות',
                        )
                      ]),
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    FormBuilderTextField(
                      key: Key(Keys.LOGIN_PASS),
                      name: 'password',
                      decoration: InputDecoration(labelText: " סיסמא "),
                      obscureText: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.min(context, 8,
                            errorText: "הסיסמא חייבת להיות לפחות באורך 8"),
                        FormBuilderValidators.required(
                          context,
                          errorText: 'שדה זה הינו חובה להתחברות',
                        )
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FlatButton(
              child: Text(
                'שכחת סיסמא?',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline),
              ),
              onPressed: () async {
                await viewModel.forgotPassword(context);
              },
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: viewModel.screenUtils.isLoading,
              builder: (BuildContext context, bool isLoading, Widget child) {
                if (isLoading) {
                  return child;
                } else {
                  return RaisedButton(
                      key: Key(Keys.LOGIN_BTN),
                      color: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      child: const Text(
                        LoginForm.SUBMIT_TEXT,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        viewModel.login();
                      });
                }
              },
              child: const CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
