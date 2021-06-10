import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../controllers/snackbar_capable.dart';
import '../../../../models/plot.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';

///
/// Form to edit the given [Plot]
///
class EditPlotForm extends StatefulHookWidget {
  ///
  /// Max length of a [Plot] or [Site]
  ///
  static const SITE_NAME_MAX_LENGTH = 25;

  ///
  /// Message to show when a required field is not filled
  ///
  static const REQUIRED_VALIDATION_ERROR = "שדה זה הכרחי להוספת חלקה";

  ///
  /// [Plot] to edit
  ///
  final Plot _initialPlot;

  EditPlotForm(this._initialPlot);

  @override
  _EditPlotFormState createState() => _EditPlotFormState(this._initialPlot);
}

class _EditPlotFormState extends State<EditPlotForm> with SnackBarCapable {
  ///
  /// [Plot] to edit
  ///
  final Plot _initialPlot;

  _EditPlotFormState(this._initialPlot);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(editPlotViewModel);
    final allSitesStream = useProvider(allSitesOfProjectStream);
    final allPlotsStream = useProvider(allPlotsOfProjectStream);
    return allSitesStream.when(
      data: (siteList) => allPlotsStream.when(
        data: (plotList) {
          final site = siteList
              .firstWhere((element) => element.id == _initialPlot.siteId);
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
                              initialValue: site,
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
                                      errorText: EditPlotForm
                                          .REQUIRED_VALIDATION_ERROR),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            FormBuilderTextField(
                              name: Constants.PLOT_NAME,
                              initialValue: _initialPlot.name,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "שם החלקה",
                                icon: Icon(Icons.construction),
                                alignLabelWithHint: true,
                              ),
                              validator: FormBuilderValidators.compose(
                                [
                                  FormBuilderValidators.required(context,
                                      errorText: EditPlotForm
                                          .REQUIRED_VALIDATION_ERROR),
                                  FormBuilderValidators.maxLength(
                                    context,
                                    EditPlotForm.SITE_NAME_MAX_LENGTH,
                                    errorText: "שם ארוך מדיי",
                                  ),
                                  (value) => plotList.fold(
                                          false,
                                          (bool previousValue, currentPlot) =>
                                              previousValue ||
                                              (currentPlot.name == value &&
                                                  currentPlot.id !=
                                                      _initialPlot.id))
                                      ? "כבר קיימת חלקה עם שם זהה"
                                      : null,
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
                  ValueListenableBuilder(
                      valueListenable: viewModel.screenUtils.isLoading,
                      builder:
                          (BuildContext context, bool isLoading, Widget child) {
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
                                  'עריכת חלקה',
                                  style: TextStyle(
                                      color: Constants.FORM_SUBMIT_TEXT_COLOR),
                                ),
                                onPressed: () {
                                  viewModel.onEditPress(context, _initialPlot);
                                },
                              ),
                              const SizedBox(width: 10),
                              RaisedButton(
                                key: Key(
                                    "${Keys.DELETE_PLOT_BTN}${widget._initialPlot.name}"),
                                padding: const EdgeInsets.all(10),
                                color: Theme.of(context).errorColor,
                                shape: StadiumBorder(),
                                child: const Text(
                                  ' מחיקת חלקה ',
                                  style: TextStyle(
                                      color: Constants.FORM_SUBMIT_TEXT_COLOR),
                                ),
                                onPressed: () {
                                  viewModel.onDeletePress(
                                      context, _initialPlot);
                                },
                              ),
                            ],
                          );
                        }
                      },
                      child: const Center(
                        child: const CircularProgressIndicator(),
                      ))
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
