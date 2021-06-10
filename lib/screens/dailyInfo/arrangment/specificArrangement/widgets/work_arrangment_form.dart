import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/constants.dart' as Constants;
import '../../../../../models/work_arrangement.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Edit [WorkArrangement] Form
///
class WorkArrangementForm extends StatefulHookWidget {
  ///
  /// Text to show on submit button of the form
  ///
  static const SUBMIT_TEXT = "שמור";

  ///
  /// if true, can be editable (by admins or managers). otherwise can view only
  ///
  final bool isEditable;

  ///
  /// [WorkArrangement] To edit
  ///
  final WorkArrangement toEdit;

  WorkArrangementForm({@required this.isEditable, @required this.toEdit});

  @override
  _WorkArrangementFormState createState() => _WorkArrangementFormState();
}

class _WorkArrangementFormState extends State<WorkArrangementForm> {
  WorkArrangement initialArrange;

  @override
  void initState() {
    if (widget.toEdit == null) {
      initialArrange = WorkArrangement(
        date: DateTime.now().add(Duration(days: 1)),
        freeTextInfo: null,
      );
    } else {
      initialArrange = WorkArrangement.copy(widget.toEdit);
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
                  key: viewModel.workArrangementsFormKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderDateTimePicker(
                        key: Key(Keys.DATE_PICKER_WORK_ARRANGEMENT),
                        name: Constants.WA_DATE,
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
                        key: Key(Keys.INFO_WORK_ARRANGEMENT),
                        name: Constants.WA_ARRANGEMENT,
                        enabled: widget.isEditable,
                        keyboardType: TextInputType.multiline,
                        initialValue: initialArrange.freeTextInfo,
                        maxLines: null,
                        minLines: 10,
                        decoration: InputDecoration(labelText: " סידור עבודה "),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: 'שדה זה הוא חובה לשמירת סידור עבודה',
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: viewModel.screenUtils.isLoading,
                child: const CircularProgressIndicator(),
                builder: (BuildContext context, bool isLoading, Widget child) =>
                    isLoading
                        ? child
                        : RaisedButton(
                            key: Key(Keys.SUBMIT_WORK_ARRANGEMENT_EDIT),
                            color: Theme.of(context).accentColor,
                            child: const Text(
                              WorkArrangementForm.SUBMIT_TEXT,
                              style: const TextStyle(color: Colors.white),
                            ),
                            shape: const StadiumBorder(),
                            onPressed: () {
                              viewModel.trySubmitWorkArrangements(context,
                                  initialArrange, widget.toEdit == null);
                            }),
              ),
            ),
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
