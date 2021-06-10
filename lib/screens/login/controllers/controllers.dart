import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../controllers/state_providers/screen_utils.dart';
import '../../../logic/EmployeeHandler.dart';
import '../../../logic/initializer.dart';

const PASSWORD = 'password';

///
/// checking if the current environment is testing environment to see if to run animations or not
///
final isTestEnv = Provider((ref) => Initializer().isTestEnv());

///
/// Provider of View Model for the login screen
///
final loginViewModel =
    Provider.autoDispose<LoginViewModel>((ref) => LoginViewModel());

///
/// View Model of the login screen
///
class LoginViewModel {
  ///
  /// Screen utils to handle snack bar, current context, and loading process
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// Key of the login form
  ///
  final formKey = GlobalKey<FormBuilderState>();

  ///
  /// Key for the Forget Password Form
  ///
  final forgotPasswordKey = GlobalKey<FormBuilderState>();

  ///
  /// logging in an existing user with the given [email] and [password].
  ///
  void login() async {
    if (formKey.currentState.saveAndValidate()) {
      final email =
          formKey.currentState.fields[Constants.EMPLOYEE_EMAIL].value as String;
      final password = formKey.currentState.fields[PASSWORD].value as String;
      this.screenUtils.isLoading.value = true;

      final msg =
          await EmployeeHandler().login(email: email, password: password);
      this.screenUtils.isLoading.value = false;
      if (msg != null && msg.isNotEmpty && msg != Constants.NOT_IN_ENV_ERROR) {
        this.screenUtils.showOnSnackBar(
              msg: msg,
              successMsg: "התחברות בוצעה בהצלחה",
            );
      }
    }
  }

  ///
  /// Show the forget password dialog and form
  ///
  Future<void> forgotPassword(BuildContext context) async {
    Alert(
        context: this.screenUtils.scaffoldKey.currentContext,
        title: "איפוס סיסמא",
        content: FormBuilder(
          key: forgotPasswordKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  name: Constants.EMPLOYEE_EMAIL,
                  initialValue: '',
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "אימייל",
                    icon: Icon(Icons.mail),
                    alignLabelWithHint: true,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      context,
                      errorText: "שדה זה הכרחי",
                    ),
                    FormBuilderValidators.email(context,
                        errorText: "אימייל לא תקין"),
                  ]),
                  valueTransformer: (val) => val?.trim(),
                ),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              final email = forgotPasswordKey.currentState
                  .fields[Constants.EMPLOYEE_EMAIL].value as String;
              if (email.trim().length == 0) {
                forgotPasswordKey.currentState.reset();
              }
              FocusScope.of(context).unfocus();

              if (forgotPasswordKey.currentState.saveAndValidate()) {
                this.screenUtils.isLoading.value = true;
                Navigator.of(context).pop();

                final msg =
                    await EmployeeHandler().sendResetPasswordLinkToEmail(email);
                this.screenUtils.isLoading.value = false;
                this.screenUtils.showOnSnackBar(
                    msg: msg, successMsg: "נשלח מייל לאיפוס הסיסמא");
              }
            },
            child: Text(
              "שלח הודעת איפוס",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
