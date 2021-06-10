import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/constants.dart' as Constants;
import '../../../../../models/drive_arrangement.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Edit [DriveArrangement] Form
///
class DriveArrangementForm extends StatefulHookWidget {
  ///
  /// Text to show on submit button of the form
  ///
  static const SUBMIT_TEXT = "שמור";

  ///
  /// if true, can be editable (by admins or managers). otherwise can view only
  ///
  final bool isEditable;

  ///
  /// [DriveArrangement] To edit
  ///
  final DriveArrangement toEdit;

  DriveArrangementForm({@required this.isEditable, @required this.toEdit});

  @override
  _DriveArrangementFormState createState() => _DriveArrangementFormState();
}

class _DriveArrangementFormState extends State<DriveArrangementForm> {
  DriveArrangement initialArrange;

  @override
  void initState() {
    if (widget.toEdit == null) {
      initialArrange = DriveArrangement(
        date: DateTime.now().add(Duration(days: 1)),
        freeTextInfo: null,
      );
    } else {
      initialArrange = DriveArrangement.copy(widget.toEdit);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(specificArrangementViewModel);
    final List<Widget> children = widget.isEditable
        ? <Widget>[
            Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilder(
                  key: viewModel.driveArrangementsFormKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderDateTimePicker(
                        key: Key(Keys.DATE_PICKER_DRIVE_ARRANGEMENT),
                        name: Constants.DA_DATE,
                        // onChanged: _onChanged,
                        locale: Localizations.localeOf(context),
                        enabled: widget.isEditable,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'תאריך',
                        ),
                        initialTime: TimeOfDay(hour: 8, minute: 0),
                        initialValue: initialArrange.date,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FormBuilderTextField(
                        key: Key(Keys.INFO_DRIVE_ARRANGEMENT),
                        name: Constants.DA_ARRANGEMENT,
                        enabled: widget.isEditable,
                        keyboardType: TextInputType.multiline,
                        initialValue: initialArrange.freeTextInfo,
                        maxLines: null,
                        minLines: 10,
                        decoration: InputDecoration(labelText: " סידור נסיעה "),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: 'שדה זה הוא חובה לשמירת סידור נסיעה',
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ValueListenableBuilder(
                valueListenable: viewModel.screenUtils.isLoading,
                builder: (BuildContext context, bool isLoading, Widget child) =>
                    isLoading
                        ? child
                        : RaisedButton(
                            key: Key(Keys.SUBMIT_DRIVE_ARRANGEMENT_EDIT),
                            color: Theme.of(context).accentColor,
                            child: const Text(
                              DriveArrangementForm.SUBMIT_TEXT,
                              style: const TextStyle(color: Colors.white),
                            ),
                            shape: const StadiumBorder(),
                            onPressed: () {
                              viewModel.trySubmitDriveArrangement(context,
                                  initialArrange, widget.toEdit == null);
                            }),
                child: const CircularProgressIndicator(),
              ),
            )
          ]
        : [
            Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(dateToString(initialArrange.date),
                          style: Theme.of(context).textTheme.headline5),
                      SizedBox(
                        height: 20,
                        width: double.infinity,
                      ),
                      Text(
                        initialArrange.freeTextInfo,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  )),
            )
          ];

    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, children: children),
    );
  }
}
