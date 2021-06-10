import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../../constants/constants.dart' as Constants;
import '../../../../../controllers/state_providers/screen_utils.dart';
import '../../../../../logic/ProjectHandler.dart';
import '../../../../../logic/dailyInfoHandler.dart';
import '../../../../../models/arrangement.dart';
import '../../../../../models/arrangement_type.dart';
import '../../../constants/keys.dart' as Keys;
import '../../specificArrangement/specific_arrangement_screen.dart';

///
/// Provider of all arrangements in project by type
///
final allArrangementsOfProjectStream = StreamProvider.autoDispose
    .family<List<Arrangement>, ArrangementType>((ref, type) =>
        DailyInfoHandler().allArrangementsFromProject(
            ProjectHandler().getCurrentProjectId(), type));

///
/// Provider of View Model for the all arrangements screen
///
final allArrangementsViewModel = Provider.autoDispose<AllArrangementsViewModel>(
    (ref) => AllArrangementsViewModel());

///
/// View Model class for the All Screen page
///
class AllArrangementsViewModel {
  final screenUtils = ScreenUtilsControllerForList<DateTime>(
    query: ValueNotifier<DateTime>(null),
    editSuccessMessage: "הסידור נערך בהצלחה",
    deleteSuccessMessage: "הסידור נמחק בהצלחה",
  );

  ///
  /// Handle the onPress of add Arrangement button
  ///
  void handleAddPress(BuildContext context, ArrangementType type) async {
    String msg = await Navigator.of(context).pushNamed(
      ArrangementScreen.routeName,
      arguments: {'arrangement': null, 'type': type},
    ) as String;
    this.screenUtils.showOnSnackBar(msg: msg, successMsg: "הסידור נוסף בהצלחה");
  }

  ///
  /// Navigate to the Edit Arrangement screen of the [arrangementType] to edit the given [arrangement]
  ///
  void navigateAndPushEditArrangement(BuildContext context,
      Arrangement arrangement, ArrangementType arrangementType) async {
    String success = arrangementType == ArrangementType.DRIVE
        ? "סידור הנסיעה עודכן בהצלחה"
        : "סידור העבודה עודכן בהצלחה";
    String result = await Navigator.of(context).pushNamed(
            ArrangementScreen.routeName,
            arguments: {'arrangement': arrangement, 'type': arrangementType})
        as String;
    FocusScope.of(context).unfocus();
    this.screenUtils.showOnSnackBar(msg: result, successMsg: success);
  }

  ///
  /// Show dialog of delete an arrangement
  ///
  void deleteArrangement(BuildContext context, Arrangement arrangement,
      ArrangementType arrangementType) async {
    final String type = arrangementType == ArrangementType.WORK
        ? Constants.ARRANGEMENT_TYPE_WORK
        : Constants.ARRANGEMENT_TYPE_DRIVE;
    final String title = "מחיקת $type";
    final String desc =
        "האם אתה בטוח שאתה רוצה למחוק את $type מתאריך ${arrangement.generateTitle()} ?";
    final String success = "$type נמחק בהצלחה";

    Alert(
      context: context,
      type: AlertType.warning,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          key: Key(Keys.SURE_DELETE_ARRANGEMENT),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            FocusScope.of(context).unfocus();
            String msg = await DailyInfoHandler()
                .deleteArrangement(arrangement.id, arrangementType);
            this.screenUtils.showOnSnackBar(msg: msg, successMsg: success);
          },
          width: 60,
          color: Theme.of(context).errorColor,
        ),
        DialogButton(
          key: Key(Keys.CANCEL_DELETE_ARRANGEMENT),
          child: Text(
            "ביטול",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
          width: 60,
        )
      ],
    ).show();
  }
}
