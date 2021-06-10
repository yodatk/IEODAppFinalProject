import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../logger.dart' as Logger;
import '../../../../models/Employee.dart';
import '../../../../models/company.dart';
import '../../../../models/project.dart';
import '../../../../widgets/employee_avatar.dart';
import '../../../../widgets/image_picker_and_shower.dart';
import '../../../../widgets/loading_circular.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Main [Widget] ion the edit project screen -> contains the form for editing the [Project] Entity
///
class EditProjectForm extends StatefulHookWidget {
  ///
  /// [Project] that is edited in this form. if null, will create a new [Project]
  ///
  final Project toEdit;

  ///
  /// List of all [Project] in the system to make sure there is no two projects with the same name
  ///
  final List<Project> allProjects;

  EditProjectForm({@required this.toEdit, @required this.allProjects});

  @override
  _EditProjectFormState createState() => _EditProjectFormState();
}

class _EditProjectFormState extends State<EditProjectForm> {
  ///
  /// [Employee] which is the manager of the edited [Project]
  ///
  Employee manager;

  ///
  /// Setting the given image from the [picked] File to be the image of the project. if the given file is null, will clear the image
  ///
  void setImage(BuildContext context, File picked) {
    final viewModel = context.read(editProjectViewModel);
    viewModel.pickedImage = picked;
    setState(() {});
  }

  ///
  /// Cancel the chosen image from the image picker.
  ///
  void cancelImage(BuildContext context) {
    final viewModel = context.read(editProjectViewModel);
    viewModel.isCanceled = true;
  }

  ///
  /// Filtering [Employee] to match the only the ones that contain [filter] in their name
  ///
  Future<List<Employee>> filterWorkers(
      List<Employee> employeesList, String filter) {
    return Future<List<Employee>>(() {
      return employeesList
          .where((employee) => employee.name.contains(filter))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider<EditProjectViewModel>(editProjectViewModel);
    final allEmployees = useProvider(allEmployeeForProject);
    final allAdmins = useProvider(allAdminsForProject);
    final oldImage = widget.toEdit != null &&
            widget.toEdit.isWithImage() &&
            !viewModel.isCanceled
        ? CachedNetworkImageProvider(widget.toEdit.imageUrl)
        : null;
    return allEmployees.when(
        data: (employees) => allAdmins.when(
            data: (admins) {
              final foundManager = widget.toEdit == null
                  ? null
                  : admins.where((employee) =>
                      employee.id == widget.toEdit.projectManagerId);
              manager = foundManager != null && foundManager.isNotEmpty
                  ? foundManager.first
                  : null;
              return SingleChildScrollView(
                child: FormBuilder(
                  key: viewModel.formKey,
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(
                            height: 10,
                          ),
                          ProjectNameField(widget.allProjects, widget.toEdit),
                          const SizedBox(
                            height: 5,
                          ),
                          FormBuilderChoiceChip(
                            key: Key(Keys.EMPLOYER_FIELD),
                            name: Constants.PROJECT_EMPLOYER,
                            spacing: 10,
                            alignment: WrapAlignment.center,
                            selectedColor: Theme.of(context).accentColor,
                            backgroundColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(),
                            initialValue: widget.toEdit != null
                                ? widget.toEdit.employer
                                : Company.IMAG,
                            options: <FormBuilderFieldOption>[
                              for (Company company in Company.values)
                                FormBuilderFieldOption(
                                    key: Key(describeEnum(company)),
                                    child: Text(
                                      describeEnum(company),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: company),
                            ],
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                context,
                                errorText: Constants.REGISTER_REQUIRED,
                              ),
                            ]),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          FormBuilderSwitch(
                            key: Key(Keys.IS_ACTIVE_FIELD),
                            initialValue: widget.toEdit == null
                                ? true
                                : widget.toEdit.isActive,
                            name: Constants.PROJECT_IS_ACTIVE,
                            title: const Text("פרויקט פעיל"),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ChosenEmployeesField(
                            Key(Keys.EMPLOYEES_FIELD),
                            widget.toEdit,
                            employees,
                            Constants.PROJECT_EMPLOYEES,
                            StyleConstants.ICON_EMPLOYEES,
                            employees.length,
                            widget.toEdit == null
                                ? <Employee>[]
                                : employees
                                    .where((e) =>
                                        widget.toEdit.employees.contains(e.id))
                                    .toList(),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownSearch<Employee>(
                            mode: Mode.DIALOG,
                            label: "  מנהל אתר  ",
                            showSearchBox: true,
                            selectedItem: manager,
                            showClearButton: true,
                            onFind: (filter) => filterWorkers(admins, filter),
                            itemAsString: (Employee u) => "  ${u.name}  ",
                            onChanged: (Employee data) {
                              manager = data;
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "תמונת רקע לפרויקט",
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                          LoadingButton(
                            onPressed: () async {
                              if (viewModel.formKey.currentState
                                  .saveAndValidate()) {
                                await viewModel.trySubmitProjectForm(
                                    context, widget.toEdit, manager);
                              }
                            },
                            isLoading: viewModel.screenUtils.isLoading,
                            text: "שמור",
                            color: StyleConstants.accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const LoadingCircularWidget(),
            error: (error, stack) => printAndShowErrorWidget(error, stack)),
        loading: () => const LoadingCircularWidget(),
        error: (error, stack) => printAndShowErrorWidget(error, stack));
  }
}

///
/// Name Field for the edit [Project] form
///
class ProjectNameField extends HookWidget {
  ///
  /// List of all [Project] to check the given name does not exists
  ///
  final List<Project> allProjects;

  ///
  /// given [Project] to Edit.
  ///
  final Project toEdit;

  const ProjectNameField(this.allProjects, this.toEdit);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      key: Key(Keys.PROJECT_NAME_FIELD),
      name: Constants.PROJECT_NAME,
      initialValue: toEdit?.name,
      decoration: const InputDecoration(
        labelText: " שם פרויקט ",
        hintText: " שם פרויקט ",
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context,
            errorText: "שדה זה הכרחי לשמירת פרויקט"),
        (value) => allProjects.fold(
                false,
                (bool previousValue, element) => (previousValue ||
                    (element.name == value && element.name != toEdit.name)))
            ? "קיים כבר פרויקט עם שם זה"
            : null
      ]),
    );
  }
}

///
/// Button with loading mechanism for the edit [Project] form
///
class LoadingButton extends HookWidget {
  final Color color;
  final String text;
  final ValueNotifier<bool> isLoading;
  final Future<void> Function() onPressed;

  LoadingButton({
    @required this.text,
    @required this.color,
    @required this.isLoading,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (BuildContext context, bool isLoading, Widget child) => isLoading
          ? child
          : RaisedButton(
              key: const Key(Keys.SUBMIT_PROJECT_BTN),
              color: color,
              shape: const StadiumBorder(),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await onPressed();
              }),
      child: const CircularProgressIndicator(),
    );
  }
}

///
/// Chip List Field for the edit [Project] form, represents all the employees in the project.
///
class ChosenEmployeesField extends HookWidget {
  final Project toEdit;
  final List<Employee> allEmployees;
  final String fieldName;
  final IconData icon;
  final int max;
  final List<Employee> initialValue;
  final Key key;

  ChosenEmployeesField(this.key, this.toEdit, this.allEmployees, this.fieldName,
      this.icon, this.max, this.initialValue);

  @override
  Widget build(BuildContext context) {
    return FormBuilderChipsInput<Employee>(
      key: key,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context,
            errorText: "שדה חובה לשמירת פרויקט"),
        (value) =>
            value == null || value.isEmpty ? "שדה חובה לשמירת פרויקט" : null
      ]),
      decoration: InputDecoration(
          labelText: fieldName, hintText: fieldName, icon: Icon(this.icon)),
      name: fieldName,
      maxChips: max,
      initialValue: initialValue,
      textOverflow: TextOverflow.visible,
      chipBuilder: (context, state, Employee e) {
        return InputChip(
          key: ObjectKey(e),
          label: Text(e.name),
          avatar: EmployeeAvatar(e),
          onDeleted: () => state.deleteChip(e),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, Employee e) {
        return ListTile(
            key: Key(e.email),
            leading: CircleAvatar(
              backgroundImage: e.isWithImage()
                  ? CachedNetworkImageProvider(e.imageUrl)
                      as ImageProvider<Object>
                  : AssetImage(StyleConstants.EMPLOYEE_PLACE_HOLDER),
              onBackgroundImageError: (error, stack) {
                Logger.errorList([
                  "Unexpected Error:",
                  error.toString(),
                  stack.toString(),
                ]);
              },
            ),
            title: Text(e.name),
            subtitle: Text(e.email),
            onTap: () => state.selectSuggestion(e));
      },
      findSuggestions: (String query) {
        if (query != null && query.isNotEmpty) {
          var lowercaseQuery = query.toLowerCase();
          return allEmployees.where((e) {
            return e.name.toLowerCase().contains(query.toLowerCase());
          }).toList(growable: false)
            ..sort((a, b) => a.name
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.name.toLowerCase().indexOf(lowercaseQuery)));
        } else {
          return allEmployees;
        }
      },
    );
  }
}
