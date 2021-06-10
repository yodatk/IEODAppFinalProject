import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../models/Employee.dart';
import '../../../../models/permission.dart';
import '../../../../widgets/image_picker_and_shower.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Form for Editing an exiting Employee
///
class EditEmployeeForm extends StatefulHookWidget {
  static const USERNAME_MAX_LENGTH = 25;
  static const USERNAME_MIN_LENGTH = 2;

  ///
  /// [Employee] to register in the form
  ///
  final Employee toEdit;

  EditEmployeeForm(this.toEdit);

  @override
  _EditEmployeeFormState createState() => _EditEmployeeFormState();
}

class _EditEmployeeFormState extends State<EditEmployeeForm> {
  ///
  /// Setting a given [picked] file as the profile image of the [Employee]
  ///
  void setImage(BuildContext context, File picked) {
    final viewModel =
        context.read<EditEmployeeViewModel>(editEmployeeViewModel);
    viewModel.pickedImage = picked;
    setState(() {});
  }

  ///
  /// Resetting the Image of this [Employee]
  ///
  void cancelImage(BuildContext context) {
    final viewModel = context.read(editEmployeeViewModel);
    viewModel.isCanceled = true;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(editEmployeeViewModel);
    final oldImage = widget.toEdit != null &&
            widget.toEdit.isWithImage() &&
            !viewModel.isCanceled
        ? CachedNetworkImageProvider(widget.toEdit.imageUrl)
        : null;

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
                        initialValue: widget.toEdit.name,
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
                            EditEmployeeForm.USERNAME_MAX_LENGTH,
                            errorText: "שם ארוך מדיי",
                          ),
                          FormBuilderValidators.minLength(
                            context,
                            EditEmployeeForm.USERNAME_MIN_LENGTH,
                            errorText: "שם קצר מדיי",
                          ),
                        ]),
                        valueTransformer: (val) =>
                            val != null ? val.trim() : val,
                      ),
                      FormBuilderTextField(
                        key: Key(Keys.EMAIL),
                        name: Constants.EMPLOYEE_EMAIL,
                        textAlign: TextAlign.right,
                        enabled: false,
                        initialValue: widget.toEdit.email,
                        decoration: InputDecoration(
                          labelText: "אימייל",
                          hintText: "אימייל",
                          alignLabelWithHint: true,
                        ),
                      ),
                      FormBuilderTextField(
                          key: Key(Keys.PHONE_NUMBER),
                          name: Constants.EMPLOYEE_PHONE_NUMBER,
                          initialValue: widget.toEdit.phoneNumber,
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
                          ])),
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
                        initialValue: widget.toEdit.permission,
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
                        initialValue: widget.toEdit.isHandWorker ?? true,
                        alignment: WrapAlignment.center,
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
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              context,
                              errorText: Constants.REGISTER_REQUIRED,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ImagePickerAndShower(
                        (File newImage) {
                          setImage(context, newImage);
                        },
                        oldImage: oldImage,
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
            ValueListenableBuilder(
              valueListenable: viewModel.screenUtils.isLoading,
              builder: (BuildContext context, bool isLoading, Widget child) {
                if (isLoading) {
                  return child;
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        key: Key(Keys.EDIT_EMPLOYEE_BTN),
                        color: Theme.of(context).accentColor,
                        shape: StadiumBorder(),
                        child: const Text(
                          ' שמור ',
                          style: TextStyle(
                              color: Constants.FORM_SUBMIT_TEXT_COLOR),
                        ),
                        onPressed: () {
                          viewModel.trySubmit(context, widget.toEdit);
                        },
                      ),
                      SizedBox(width: 10),
                      RaisedButton(
                        key: Key(Keys.DELETE_EMPLOYEE_BTN),
                        padding: const EdgeInsets.all(10),
                        color: Theme.of(context).errorColor,
                        shape: StadiumBorder(),
                        child: const Text(
                          ' מחק ',
                          style: TextStyle(
                              color: Constants.FORM_SUBMIT_TEXT_COLOR),
                        ),
                        onPressed: () {
                          // unfocusing the form, and try to submit only of form is validated
                          FocusScope.of(context).unfocus();

                          Alert(
                            context: context,
                            type: AlertType.warning,
                            title: "מחיקת עובד",
                            desc:
                                "האם אתה בטוח שאתה רוצה למחוק את העובד '${widget.toEdit.name}'",
                            buttons: [
                              DialogButton(
                                key: Key(Keys.SURE_DELETE_OK_BUTTON_KEY),
                                child: Text(
                                  "כן",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  viewModel.removeEmployee(
                                    context: context,
                                    toDelete: widget.toEdit,
                                  );
                                },
                                width: 60,
                                color: Theme.of(context).errorColor,
                              ),
                              DialogButton(
                                key: Key(Keys.SURE_DELETE_CANCEL_BUTTON_KEY),
                                child: Text(
                                  "ביטול",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                width: 60,
                              )
                            ],
                          ).show();
                        },
                      ),
                    ],
                  );
                }
              },
              child: const Center(
                child: const CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
