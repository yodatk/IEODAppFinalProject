import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/snackbar_capable.dart';
import '../../../../models/site.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Form to add a new [Plot] to a [Site] in [Project]
///
class AddNewPlotToSiteForm extends StatefulHookWidget {
  ///
  /// Max Length of a name of a Plot
  ///
  static const SITE_NAME_MAX_LENGTH = 25;

  ///
  /// Message to show when a required field is not filled in the add [Plot] Form
  ///
  static const REQUIRED_VALIDATION_ERROR = "שדה זה הכרחי להוספת חלקה";

  ///
  /// [Site] to add a [Plot] to
  ///
  final Site _initialSite;

  AddNewPlotToSiteForm(this._initialSite);

  @override
  _AddNewPlotToSiteFormState createState() =>
      _AddNewPlotToSiteFormState(this._initialSite);
}

class _AddNewPlotToSiteFormState extends State<AddNewPlotToSiteForm>
    with SnackBarCapable {
  ///
  /// [Site] to add a [Plot] to
  ///
  final Site _initialSite;

  _AddNewPlotToSiteFormState(this._initialSite);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(addPlotViewModel);
    final allSitesStream = useProvider(allSitesOfProjectStream);
    final allPlotsStream = useProvider(allPlotsOfProjectStream);
    return allSitesStream.when(
      data: (siteList) => allPlotsStream.when(
        data: (plotList) {
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
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: const Text(
                                "אתרים",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            FormBuilderChoiceChip(
                              name: Constants.PLOT_SITE_ID,
                              spacing: 10,
                              initialValue: siteList.firstWhere(
                                  (site) => site.id == _initialSite.id,
                                  orElse: null),
                              alignment: WrapAlignment.center,
                              selectedColor: Theme.of(context).accentColor,
                              backgroundColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(),
                              options: siteList
                                  .map((e) => FormBuilderFieldOption(
                                        child: Text(
                                          e.name,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value: e,
                                      ))
                                  .toList(),
                              validator: FormBuilderValidators.compose(
                                [
                                  FormBuilderValidators.required(context,
                                      errorText: AddNewPlotToSiteForm
                                          .REQUIRED_VALIDATION_ERROR),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            FormBuilderTextField(
                              key: Key(Keys.ADD_PLOT_NAME_FIELD),
                              name: Constants.PLOT_NAME,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "שם החלקה",
                                icon: Icon(Icons.construction),
                                alignLabelWithHint: true,
                              ),
                              validator: FormBuilderValidators.compose(
                                [
                                  FormBuilderValidators.required(context,
                                      errorText: AddNewPlotToSiteForm
                                          .REQUIRED_VALIDATION_ERROR),
                                  FormBuilderValidators.maxLength(
                                    context,
                                    AddNewPlotToSiteForm.SITE_NAME_MAX_LENGTH,
                                    errorText: "שם ארוך מדיי",
                                  ),
                                  (value) => plotList.fold(
                                          false,
                                          (bool previousValue, plot) =>
                                              previousValue ||
                                              plot.name == value)
                                      ? "החלקה הזו קיימת כבר בפרויקט"
                                      : null
                                ],
                              ),
                              valueTransformer: (val) =>
                                  val != null ? val.trim() : val,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.screenUtils.isLoading,
                        builder: (BuildContext context, bool isLoading,
                            Widget child) {
                          if (isLoading) {
                            return child;
                          } else {
                            return RaisedButton(
                              key: Key(Keys.ADD_PLOT_SUBMIT_FIELD),
                              color: Theme.of(context).accentColor,
                              shape: StadiumBorder(),
                              child: Text(
                                'הוספת חלקה',
                                style: TextStyle(
                                    color: Constants.FORM_SUBMIT_TEXT_COLOR),
                              ),
                              onPressed: () {
                                viewModel.onPressedForm(context);
                              },
                            );
                          }
                        },
                        child: const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: loadingDataWidget,
        error: printAndShowErrorWidget,
      ),
      loading: loadingDataWidget,
      error: printAndShowErrorWidget,
    );
  }
}
