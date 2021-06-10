import 'package:IEODApp/screens/managesSiteAndPlots/all_strips_screen/controllers/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/constants.dart' as Constants;
import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../logic/fieldHandler.dart';
import '../../../../models/plot.dart';
import '../../../../models/strip.dart';
import '../../constants/keys.dart' as Keys;

///
/// Form to add one or many [Strips]
///
class AddStripForm extends HookWidget {
  ///
  /// Key of the edit [Strip] form
  ///
  final GlobalKey<FormBuilderState> formKey;

  ///
  /// [Plot] where the strip belong to
  ///
  final Plot plot;

  ///
  /// Key for the [Strip] to start from (when adding multiple [Strip])
  ///
  static const START = "${Constants.STRIP_NAME}1";

  ///
  /// Key for the [Strip] to end with (when adding multiple [Strip])
  ///
  static const END = "${Constants.STRIP_NAME}2";

  AddStripForm(this.formKey, this.plot);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allStripsViewModel);
    final allStrips = FieldHandler().getAllCurrentStrips();
    final sortedNumericStrips = allStrips
        .where((strip) => int.tryParse(strip.name) != null)
        .toList()
          ..sort((s1, s2) => s1.compareTo(s2));
    final namesOnly = sortedNumericStrips.map((e) => e.name);
    final firstAvailableNumericStrip = (sortedNumericStrips.isEmpty
            ? 1
            : int.parse(sortedNumericStrips.last.name) + 1)
        .toString();
    return FormBuilder(
      key: formKey,
      child: SingleChildScrollView(
        child: ValueListenableBuilder(
          child: FormBuilderSwitch(
            name: "multipleSwitch",
            title: const Text("יחיד\\רבים"),
            initialValue: viewModel.isMultipleAddForm.value,
            onChanged: (value) => viewModel.isMultipleAddForm.value = value,
          ),
          valueListenable: viewModel.isMultipleAddForm,
          builder: (BuildContext context, bool isMultiple, Widget child) {
            if (isMultiple) {
              return Column(
                children: <Widget>[
                  child,
                  FormBuilderTextField(
                    key: Key("${Keys.ADD_STRIP_ALERT_NAME_FIELD}${plot.name}1"),
                    name: START,
                    initialValue: firstAvailableNumericStrip,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "סטריפ ראשון",
                      icon: Icon(StyleConstants.ICON_ADD_STRIP),
                      alignLabelWithHint: true,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        context,
                        errorText: "שדה זה דרוש להוספת טווח סטריפים",
                      ),
                      FormBuilderValidators.numeric(context,
                          errorText: "בבחירת טווח הסטריפ חייב להיות מספר"),
                    ]),
                    valueTransformer: (val) => val != null ? val.trim() : val,
                  ),
                  FormBuilderTextField(
                    key: Key("${Keys.ADD_STRIP_ALERT_NAME_FIELD}${plot.name}2"),
                    name: END,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "סטריפ אחרון",
                      icon: Icon(StyleConstants.ICON_ADD_STRIP),
                      alignLabelWithHint: true,
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.required(
                          context,
                          errorText: "שדה זה דרוש להוספת טווח סטריפים",
                        ),
                        FormBuilderValidators.numeric(context,
                            errorText: "בבחירת טווח הסטריפ חייב להיות מספר"),
                        (end) {
                          final start = formKey.currentState.fields[START].value
                              as String;
                          if (start == null) {
                            return "טווח לא רציף";
                          }
                          final startIntVal = int.tryParse(start);
                          final endIntVal = int.tryParse(end);
                          if (startIntVal == null ||
                              endIntVal == null ||
                              startIntVal >= endIntVal) {
                            return "טווח לא רציף";
                          }
                          var alreadyExists = "";
                          for (int i = startIntVal; i <= endIntVal; i++) {
                            if (namesOnly.contains(i.toString())) {
                              alreadyExists += '${i.toString()},';
                            }
                          }
                          if (alreadyExists != "") {
                            alreadyExists = alreadyExists.substring(
                                0, alreadyExists.length - 1);
                            return "קיימים כבר: $alreadyExists";
                          }
                          return null;
                        }
                      ],
                    ),
                    valueTransformer: (val) => val != null ? val.trim() : val,
                  ),
                ],
              );
            } else {
              return Column(
                children: <Widget>[
                  child,
                  FormBuilderTextField(
                    key: Key("${Keys.ADD_STRIP_ALERT_NAME_FIELD}${plot.name}"),
                    name: Constants.STRIP_NAME,
                    initialValue: firstAvailableNumericStrip,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "שם הסטריפ",
                      icon: Icon(StyleConstants.ICON_ADD_STRIP),
                      alignLabelWithHint: true,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        context,
                        errorText: "שדה זה דרוש להוספת סטריפ",
                      ),
                      FormBuilderValidators.maxLength(
                        context,
                        Strip.MAX_STRIP_NAME_LENGTH,
                        errorText: "שם ארוך מדיי",
                      ),
                      (value) {
                        final check =
                            allStrips.where((element) => element.name == value);
                        return check.isNotEmpty
                            ? "שם הסטריפ הזה קיים כבר"
                            : null;
                      }
                    ]),
                    valueTransformer: (val) => val != null ? val.trim() : val,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
