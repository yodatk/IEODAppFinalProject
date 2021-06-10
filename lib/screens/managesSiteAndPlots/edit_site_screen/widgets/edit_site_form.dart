import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../models/site.dart';
import '../controllers/controllers.dart';

///
/// Form to edit a [Site] Entity
///
class EditSiteForm extends HookWidget {
  static const SITE_NAME = "site";
  static const SITE_NAME_MAX_LENGTH = 25;
  static const REQUIRED_VALIDATION_ERROR = "שדה זה הכרחי להוספת פלגה";
  static const USER_NOT_FOUND = "המשתמש המבוקש כבר לא במערכת";

  ///
  /// [Site] to edit
  ///
  final Site initialSite;

  EditSiteForm(this.initialSite);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(editSiteViewModel);
    return SingleChildScrollView(
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
                      name: EditSiteForm.SITE_NAME,
                      textAlign: TextAlign.right,
                      initialValue: initialSite.name,
                      decoration: InputDecoration(
                        icon: Icon(Icons.engineering),
                        hintText: "שם האתר",
                        alignLabelWithHint: true,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          context,
                          errorText: EditSiteForm.REQUIRED_VALIDATION_ERROR,
                        ),
                        FormBuilderValidators.maxLength(
                          context,
                          EditSiteForm.SITE_NAME_MAX_LENGTH,
                          errorText: "שם ארוך מדיי",
                        ),
                      ]),
                      valueTransformer: (val) => val.trim(),
                    ),
                    SizedBox(
                      height: 15,
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
                      color: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      child: const Text(
                        'עריכת אתר',
                        style:
                            TextStyle(color: Constants.FORM_SUBMIT_TEXT_COLOR),
                      ),
                      onPressed: () {
                        viewModel.trySubmit(context, initialSite);
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      key: Key("delSiteBtn_${initialSite.name}"),
                      padding: const EdgeInsets.all(10),
                      color: Theme.of(context).errorColor,
                      shape: StadiumBorder(),
                      child: const Text(
                        ' מחיקת אתר ',
                        style:
                            TextStyle(color: Constants.FORM_SUBMIT_TEXT_COLOR),
                      ),
                      onPressed: () {
                        viewModel.tryDelete(context, initialSite);
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
    );
  }
}
