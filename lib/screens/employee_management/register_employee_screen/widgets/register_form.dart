import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../models/permission.dart';
import '../../../../widgets/image_picker_and_shower.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Form for Registering [Employee]
///
class RegisterEmployeeForm extends StatefulHookWidget {
  static const String PASSWORD = "Password";
  static const USERNAME_MAX_LENGTH = 25;
  static const USERNAME_MIN_LENGTH = 2;

  @override
  _RegisterEmployeeFormState createState() => _RegisterEmployeeFormState();
}

class _RegisterEmployeeFormState extends State<RegisterEmployeeForm> {
  ///
  /// Setting a given [picked] file as the profile image of the [Employee]
  ///
  void setImage(BuildContext context, File picked) {
    final viewModel =
        context.read<RegisterEmployeeViewModel>(registerEmployeeViewModel);
    viewModel.pickedImage = picked;
    setState(() {});
  }

  ///
  /// Resetting the Image of this [Employee]
  ///
  void cancelImage(BuildContext context) {
    final viewModel = context.read(registerEmployeeViewModel);
    viewModel.isCanceled = true;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(registerEmployeeViewModel);
    final node = FocusScope.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: FormBuilder(
                  key: viewModel.formKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        key: Key(Keys.FULL_NAME),
                        name: Constants.EMPLOYEE_NAME,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: "שם מלא",
                          hintText: "שם מלא",
                          alignLabelWithHint: true,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: Constants.REGISTER_REQUIRED,
                          ),
                          FormBuilderValidators.maxLength(
                            context,
                            RegisterEmployeeForm.USERNAME_MAX_LENGTH,
                            errorText: "שם ארוך מדיי",
                          ),
                          FormBuilderValidators.minLength(
                            context,
                            RegisterEmployeeForm.USERNAME_MIN_LENGTH,
                            errorText: "שם קצר מדיי",
                          ),
                        ]),
                        valueTransformer: (val) =>
                            val != null ? val.trim() : val,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                      ),
                      FormBuilderTextField(
                        key: Key(Keys.PHONE_NUMBER),
                        name: Constants.EMPLOYEE_PHONE_NUMBER,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'פלאפון',
                          hintText: 'פלאפון',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.match(
                            context,
                            r'^(?:[+0]9)?[0-9]{9,11}$',
                            errorText: "לא פלאפון תקין",
                          ),
                          (val) {
                            if ((val.isNotEmpty) &&
                                (val[0] != '0' && val[0] != '+')) {
                              return "לא פלאפון תקין";
                            }

                            return null;
                          }
                        ]),
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                      ),
                      FormBuilderTextField(
                        key: Key(Keys.EMAIL),
                        name: Constants.EMPLOYEE_EMAIL,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: Constants.EMPLOYEE_EMAIL,
                          hintText: Constants.EMPLOYEE_EMAIL,
                          alignLabelWithHint: true,
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              context,
                              errorText: Constants.REGISTER_REQUIRED,
                            ),
                            FormBuilderValidators.email(
                              context,
                              errorText: "הכנס כתובת אימייל תקינה",
                            ),
                          ],
                        ),
                        valueTransformer: (val) =>
                            val != null ? val.trim() : val,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                      ),
                      FormBuilderTextField(
                        key: Key(Keys.PASS1),
                        name: Constants.PASSWORD,
                        obscureText: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: "סיסמא",
                          hintText: "סיסמא",
                          alignLabelWithHint: true,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: Constants.REGISTER_REQUIRED,
                          ),
                          FormBuilderValidators.minLength(
                            context,
                            Constants.PASSWORD_MIN_LENGTH,
                            errorText: Constants.MIN_PASS_LENGTH_MSG,
                          ),
                        ]),
                        valueTransformer: (val) => val.toString().trim(),
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                      ),
                      FormBuilderTextField(
                        key: Key(Keys.PASS2),
                        name: "confirm_password",
                        obscureText: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: "וידוא סיסמא",
                          hintText: "וידוא סיסמא",
                          alignLabelWithHint: true,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: Constants.REGISTER_REQUIRED,
                          ),
                          (val) {
                            if (viewModel.formKey.currentState
                                    .fields[Constants.PASSWORD].value !=
                                val) {
                              return "הסיסמאות לא תואמות";
                            }
                            return null;
                          }
                        ]),
                        valueTransformer: (val) =>
                            val != null ? val.trim() : val,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: const Text(
                          "הרשאות",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      FormBuilderChoiceChip(
                        name: Constants.EMPLOYEE_PERMISSION,
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        selectedColor: Theme.of(context).accentColor,
                        backgroundColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(),
                        options: [
                          FormBuilderFieldOption(
                              key: Key(describeEnum(Permission.REGULAR)),
                              child: Text(
                                "רגיל",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: Permission.REGULAR),
                          FormBuilderFieldOption(
                              key: Key(describeEnum(Permission.MANAGER)),
                              child: Text(
                                "מנהל",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: Permission.MANAGER),
                          FormBuilderFieldOption(
                              key: Key(describeEnum(Permission.ADMIN)),
                              child: Text(
                                "אדמין",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: Permission.ADMIN),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: Constants.REGISTER_REQUIRED,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: const Text(
                          "סוג עובד",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      FormBuilderChoiceChip(
                        name: Constants.EMPLOYEE_IS_HAND_WORKER,
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        initialValue: true,
                        selectedColor: Theme.of(context).accentColor,
                        backgroundColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(),
                        options: [
                          FormBuilderFieldOption(
                              key: Key(Keys.IS_HAND_WORKER),
                              child: Text(
                                "ידני",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: true),
                          FormBuilderFieldOption(
                              key: Key(Keys.IS_NOT_HAND_WORKER),
                              child: Text(
                                "מכאני",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: false),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: Constants.REGISTER_REQUIRED,
                          ),
                        ]),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ImagePickerAndShower(
                        (File newImage) {
                          setImage(context, newImage);
                        },
                        deleteImage: () {
                          cancelImage(context);
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: viewModel.screenUtils.isLoading,
                  child: const CircularProgressIndicator(),
                  builder:
                      (BuildContext context, bool isLoading, Widget child) =>
                          isLoading
                              ? child
                              : RaisedButton(
                                  key: Key(Keys.ADD_EMPLOYEE_BTN),
                                  color: Theme.of(context).accentColor,
                                  shape: StadiumBorder(),
                                  child: const Text(
                                    'הוספת עובד חדש',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    // unfocusing the form, and try to submit only of form is validated
                                    viewModel.trySubmit(context);
                                  },
                                ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
