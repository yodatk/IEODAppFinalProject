import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/snackbar_capable.dart';
import '../../../../models/strip.dart';
import '../../../../models/stripJob.dart';
import '../../../../widgets/loading_circular.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// class to represents the key elements of an [Employee] when talking about [Strip]
///
class HandWorker {
  ///
  /// ID of the [Employee]
  ///
  final String id;

  ///
  /// Name of the [Employee]
  ///
  final String name;

  HandWorker(this.id, this.name);

  @override
  String toString() {
    return "$name , $id";
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HandWorker &&
            other.id == this.id &&
            other.name == other.name);
  }

  @override
  int get hashCode => this.id.hashCode;
}

///
/// Form for edit a given [Strip]
///
class EditStripForm extends StatefulHookWidget {
  final Strip toEdit;

  EditStripForm({@required this.toEdit});

  @override
  _EditStripFormState createState() => _EditStripFormState();
}

class _EditStripFormState extends State<EditStripForm> with SnackBarCapable {
  HandWorker employee1;
  HandWorker employee2;
  HandWorker employee3;
  List<HandWorker> handEmployees1;
  List<HandWorker> handEmployees2;
  List<HandWorker> handEmployees3;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  void _trySubmit(BuildContext contex) async {
    FocusScope.of(contex).unfocus();
    final viewModel = contex.read(allStripsViewModel);
    final stripToUpdate = Strip.copy(widget.toEdit);
    stripToUpdate.mineCount =
        _formKey.currentState.fields[Constants.STRIP_MINE_COUNT].value as int;
    stripToUpdate.depthTargetCount =
        _formKey.currentState.fields[Constants.STRIP_DEPTH_COUNT].value as int;
    StripJob job1 = stripToUpdate.first;
    StripJob job2 = stripToUpdate.second;
    StripJob job3 = stripToUpdate.third;
    if ((employee1 == null && widget.toEdit.first != null) ||
        (employee1 != null && widget.toEdit.first == null) ||
        (widget.toEdit.first != null &&
            employee1.id != widget.toEdit.first.employeeId) ||
        ((widget.toEdit.first != null) &&
            (widget.toEdit.first.isDone !=
                _formKey.currentState.fields[Constants.STRIP_STATUS_FIRST]
                    .value))) {
      job1 = (employee1 == null)
          ? null
          : StripJob(
              employeeId: employee1.id,
              employeeName: employee1.name,
              lastModifiedDate: DateTime.now(),
              isDone: _formKey.currentState.fields[Constants.STRIP_STATUS_FIRST]
                  .value as bool,
            );
    }

    if ((employee2 == null && widget.toEdit.second != null) ||
        (employee2 != null && widget.toEdit.second == null) ||
        (widget.toEdit.second != null &&
            employee2.id != widget.toEdit.second.employeeId) ||
        ((widget.toEdit.second != null) &&
            (widget.toEdit.second.isDone !=
                _formKey.currentState.fields[Constants.STRIP_STATUS_SECOND]
                    .value))) {
      job2 = (employee2 == null)
          ? null
          : StripJob(
              employeeId: employee2.id,
              employeeName: employee2.name,
              lastModifiedDate: DateTime.now(),
              isDone: _formKey.currentState
                  .fields[Constants.STRIP_STATUS_SECOND].value as bool,
            );
    }
    if ((employee3 == null && widget.toEdit.third != null) ||
        (employee3 != null && widget.toEdit.third == null) ||
        (widget.toEdit.third != null &&
            employee3.id != widget.toEdit.third.employeeId) ||
        ((widget.toEdit.third != null) &&
            (widget.toEdit.third.isDone !=
                _formKey.currentState.fields[Constants.STRIP_STATUS_FINISHED]
                    .value))) {
      job3 = (employee3 == null)
          ? null
          : StripJob(
              employeeId: employee3.id,
              employeeName: employee3.name,
              lastModifiedDate: DateTime.now(),
              isDone: _formKey.currentState
                  .fields[Constants.STRIP_STATUS_FINISHED].value as bool,
            );
    }
    stripToUpdate.first = job1;
    stripToUpdate.second = job2;
    stripToUpdate.third = job3;

    final status = stripToUpdate.updateStripStatus();
    if (status == null) {
      viewModel.screenUtils.showOnSnackBar(msg: "הסטריפ לא נמצא בסטטוס תקין");
    } else {
      final old = widget.toEdit.toJson();
      final changes = stripToUpdate.toJson();
      changes.removeWhere((key, value) => value == old[key]);
      if (changes.isEmpty) {
        viewModel.screenUtils.showOnSnackBar(msg: "לא שינית דבר");
      }
      Navigator.of(contex).pop();
      viewModel.updateStrip(
        toUpdate: stripToUpdate,
        changes: changes,
      );
    }
  }

  Future<List<HandWorker>> filterWorkers(
      List<HandWorker> employeesList, String filter) {
    return Future<List<HandWorker>>(() {
      return employeesList.where((user) => user.name.contains(filter)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeesFuture = useProvider(allHandWorkersProvider);
    final viewModel = useProvider(allStripsViewModel);
    return employeesFuture.when(
        data: (employees) {
          handEmployees1 =
              employees.map((e) => HandWorker(e.id, e.name)).toList();
          handEmployees2 =
              employees.map((e) => HandWorker(e.id, e.name)).toList();
          handEmployees3 =
              employees.map((e) => HandWorker(e.id, e.name)).toList();

          employee1 = widget.toEdit.first != null
              ? HandWorker(widget.toEdit.first.employeeId,
                  widget.toEdit.first.employeeName)
              : null;
          employee2 = widget.toEdit.second != null
              ? HandWorker(widget.toEdit.second.employeeId,
                  widget.toEdit.second.employeeName)
              : null;

          employee3 = widget.toEdit.third != null
              ? HandWorker(widget.toEdit.third.employeeId,
                  widget.toEdit.third.employeeName)
              : null;

          if (employee1 != null) {
            var filtered = handEmployees1
                .where((element) => element.id == employee1.id)
                .toList();
            if (filtered.isEmpty) {
              handEmployees1.add(employee1);
            }

            if (employee2 != null) {
              var filtered = handEmployees2
                  .where((element) => element.id == employee2.id)
                  .toList();
              if (filtered.isEmpty) {
                handEmployees2.add(employee2);
              }
              if (employee3 != null) {
                var filtered = handEmployees3
                    .where((element) => element.id == employee3.id)
                    .toList();

                if (filtered.isEmpty) {
                  handEmployees3.add(employee3);
                }
              }
            }
          }
          return SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.toEdit.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 3),
                      DropdownSearch<HandWorker>(
                        mode: Mode.DIALOG,
                        label: "  עובד בפעולה ראשונה  ",
                        showSearchBox: true,
                        selectedItem: employee1,
                        showClearButton: true,
                        onFind: (filter) =>
                            filterWorkers(handEmployees1, filter),
                        itemAsString: (HandWorker u) => "  ${u.name}  ",
                        onChanged: (HandWorker data) {
                          employee1 = data;
                        },
                      ),
                      SizedBox(height: 3),
                      FormBuilderSwitch(
                        title: Text("גמור"),
                        name: Constants.STRIP_STATUS_FIRST,
                        initialValue: widget.toEdit.first != null
                            ? widget.toEdit.first.isDone
                            : false,
                        validator: (value) {
                          if (value) {
                            if (employee1 == null) {
                              return "חייב לציין עובד שסיים את הפעולה הראשונה";
                            } else {
                              return null;
                            }
                          } else {
                            if (employee2 == null &&
                                employee3 == null &&
                                !(_formKey
                                    .currentState
                                    .fields[Constants.STRIP_STATUS_SECOND]
                                    .value as bool) &&
                                !(_formKey
                                    .currentState
                                    .fields[Constants.STRIP_STATUS_FINISHED]
                                    .value as bool)) {
                              return null;
                            } else {
                              return " לא ניתן להוסיף פעולה שנייה או ביקורת ללא פעולה ראשונה";
                            }
                          }
                        },
                      ),
                      SizedBox(height: 3),
                      DropdownSearch<HandWorker>(
                        mode: Mode.DIALOG,
                        label: "  עובד בפעולה שנייה  ",
                        showSearchBox: true,
                        selectedItem: employee2,
                        showClearButton: true,
                        onFind: (filter) =>
                            filterWorkers(handEmployees2, filter),
                        itemAsString: (HandWorker u) => "  ${u.name}  ",
                        onChanged: (HandWorker data) {
                          employee2 = data;
                        },
                      ),
                      SizedBox(height: 3),
                      FormBuilderSwitch(
                        title: Text("גמור"),
                        name: Constants.STRIP_STATUS_SECOND,
                        initialValue: widget.toEdit.second != null
                            ? widget.toEdit.second.isDone
                            : false,
                        validator: (value) {
                          if (value) {
                            if (employee2 != null &&
                                employee1 != null &&
                                _formKey
                                    .currentState
                                    .fields[Constants.STRIP_STATUS_FIRST]
                                    .value as bool) {
                              return null;
                            } else {
                              return "לא מצב תקין. או שפעולה ראשונה חסרה, או שחסר עובד לפעולה שנייה";
                            }
                          } else {
                            if (employee3 == null &&
                                !(_formKey
                                    .currentState
                                    .fields[Constants.STRIP_STATUS_FINISHED]
                                    .value as bool)) {
                              return null;
                            } else {
                              return "לא מצב תקין. קיימת פעולת ביקורת לפני פעולה שנייה";
                            }
                          }
                        },
                      ),
                      SizedBox(height: 3),
                      DropdownSearch<HandWorker>(
                        mode: Mode.DIALOG,
                        label: "  עובד בביקורת  ",
                        showSearchBox: true,
                        selectedItem: employee3,
                        showClearButton: true,
                        onFind: (filter) =>
                            filterWorkers(handEmployees3, filter),
                        itemAsString: (HandWorker u) => "  ${u.name}  ",
                        onChanged: (HandWorker data) {
                          employee3 = data;
                        },
                      ),
                      SizedBox(height: 3),
                      FormBuilderSwitch(
                        title: Text("גמור"),
                        name: Constants.STRIP_STATUS_FINISHED,
                        initialValue: widget.toEdit.third != null
                            ? widget.toEdit.third.isDone
                            : false,
                        validator: (value) {
                          if (value) {
                            if (_formKey
                                    .currentState
                                    .fields[Constants.STRIP_STATUS_FIRST]
                                    .value as bool &&
                                _formKey
                                    .currentState
                                    .fields[Constants.STRIP_STATUS_SECOND]
                                    .value as bool &&
                                employee1 != null &&
                                employee2 != null &&
                                employee3 != null)
                              return null;
                            else {
                              return "חסרות פעולות ראשונה ושנייה עם שיבוצים תקינים";
                            }
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 3),
                      FormBuilderTouchSpin(
                        name: Constants.STRIP_MINE_COUNT,
                        initialValue: widget.toEdit.mineCount,
                        step: 1,
                        decoration: InputDecoration(
                          labelText: 'מספר מטרות',
                        ),
                        min: 0,
                        iconSize: 20,
                        addIcon: Icon(Icons.add),
                        subtractIcon: Icon(Icons.remove),
                      ),
                      SizedBox(height: 3),
                      FormBuilderTouchSpin(
                        name: Constants.STRIP_DEPTH_COUNT,
                        initialValue: widget.toEdit.depthTargetCount,
                        step: 1,
                        decoration: InputDecoration(
                          labelText: 'מטרות עומק',
                        ),
                        min: 0,
                        iconSize: 20,
                        addIcon: Icon(Icons.add),
                        subtractIcon: Icon(Icons.remove),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //if (widget._isLoading) CircularProgressIndicator(),
                          //if (!widget._isLoading)
                          RaisedButton(
                            key: Key(Keys.EDIT_STRIP_SUBMIT_BTN),
                            color: Theme.of(context).accentColor,
                            shape: StadiumBorder(),
                            child: const Text(
                              'שמור',
                              style: TextStyle(
                                  color: Constants.FORM_SUBMIT_TEXT_COLOR),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState.saveAndValidate()) {
                                _trySubmit(context);
                              }
                            },
                          ),
                          //if (!widget._isLoading)
                          SizedBox(width: 10),
                          //if (!widget._isLoading)
                          RaisedButton(
                            key: Key(Keys.DELETE_STRIP_SUBMIT_BTN),
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
                                title: "מחיקת סטריפ",
                                desc:
                                    "האם אתה בטוח שאתה רוצה למחוק את סטריפ '${widget.toEdit.name}'",
                                buttons: [
                                  DialogButton(
                                    key: Key(Keys.SURE_TO_DELETE_STRIP),
                                    child: Text(
                                      "כן",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      viewModel.deleteStrip(
                                        toDelete: widget.toEdit,
                                      );
                                    },
                                    width: 60,
                                    color: Theme.of(context).errorColor,
                                  ),
                                  DialogButton(
                                    key: Key(Keys.CANCEL_TO_DELETE_STRIP),
                                    child: Text(
                                      "ביטול",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    width: 60,
                                  )
                                ],
                              ).show();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => LoadingCircularWidget(),
        error: (err, stack) => printAndShowErrorWidget(err, stack));
  }
}
