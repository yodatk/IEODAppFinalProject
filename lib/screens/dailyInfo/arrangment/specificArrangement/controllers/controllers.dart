import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/constants.dart' as Constants;
import '../../../../../controllers/state_providers/screen_utils.dart';
import '../../../../../logic/ProjectHandler.dart';
import '../../../../../logic/dailyInfoHandler.dart';
import '../../../../../models/arrangement.dart';
import '../../../../../models/drive_arrangement.dart';
import '../../../../../models/work_arrangement.dart';
import '../../../../../utils/datetime_utils.dart';

///
/// Provider for the View Model of the Specific Arrangements screen
///
final specificArrangementViewModel =
    Provider.autoDispose<SpecificArrangementsViewModel>(
        (ref) => SpecificArrangementsViewModel());

///
/// View Model class for the specific Arrangement screen
///
class SpecificArrangementsViewModel {
  final screenUtils = ScreenUtilsController();
  final driveArrangementsFormKey = GlobalKey<FormBuilderState>();
  final workArrangementsFormKey = GlobalKey<FormBuilderState>();

  ///
  /// Trying to submit a new [Arrangement] and shows the result of the process in the snackbar
  ///
  void submitArrangement({
    BuildContext context,
    Arrangement newArrangement,
    bool isNew,
  }) async {
    this.screenUtils.isLoading.value = true;
    String msg =
        await DailyInfoHandler().addOrOverrideArrangement(newArrangement);
    Navigator.of(context).pop(msg);
    this.screenUtils.isLoading.value = false;
  }

  ///
  /// Trying to validate and submit the data from the [DriveArrangement] from
  ///
  void trySubmitDriveArrangement(
      BuildContext context, DriveArrangement newArrangement, bool isNew) async {
    if (driveArrangementsFormKey.currentState.saveAndValidate()) {
      final date = driveArrangementsFormKey
          .currentState.fields[Constants.DA_DATE].value as DateTime;
      final arrangement = driveArrangementsFormKey
          .currentState.fields[Constants.DA_ARRANGEMENT].value as String;
      newArrangement.date = date;
      newArrangement.freeTextInfo = arrangement;
      newArrangement.timeModified = DateTime.now();
      List<DriveArrangement> all = await DailyInfoHandler()
          .allDriveArrangementsFromProjectAsItems(
              ProjectHandler().getCurrentProjectId());
      if (all
              .where((element) => ((element.id != newArrangement.id) &&
                  (dateToString(element.date) ==
                      dateToString(newArrangement.date))))
              .length !=
          0) {
        // found another drivw arrangement for that day
        final msg = "כבר יש סידור נסיעה ליום זה.";
        this.screenUtils.showOnSnackBar(msg: msg);
        return;
      }

      submitArrangement(
          newArrangement: newArrangement, context: context, isNew: isNew);
    }
  }

  ///
  /// Trying to validate and submit the data from the [WorkArrangement] from
  ///
  void trySubmitWorkArrangements(
      BuildContext context, WorkArrangement newArrangement, bool isNew) async {
    if (workArrangementsFormKey.currentState.saveAndValidate()) {
      final date = workArrangementsFormKey
          .currentState.fields[Constants.WA_DATE].value as DateTime;
      final arrangement = workArrangementsFormKey
          .currentState.fields[Constants.WA_ARRANGEMENT].value as String;
      newArrangement.date = date;
      newArrangement.freeTextInfo = arrangement;
      newArrangement.timeModified = DateTime.now();
      List<WorkArrangement> all = await DailyInfoHandler()
          .allWorkArrangementsFromProjectAsItems(
              ProjectHandler().getCurrentProjectId());
      if (all
              .where((element) => ((element.id != newArrangement.id) &&
                  (dateToString(element.date) ==
                      dateToString(newArrangement.date))))
              .length !=
          0) {
        // found another work arrangement for that day
        final msg = "כבר יש סידור עבודה ליום זה.";
        this.screenUtils.showOnSnackBar(msg: msg);
        return;
      }

      submitArrangement(
          newArrangement: newArrangement, context: context, isNew: isNew);
    }
  }
}
