library registration_utils;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/constants/style_constants.dart' as StyleConstants;
import '../../lib/screens/dailyInfo/constants/keys.dart' as DailyInfoKeys;
import '../../lib/screens/dailyInfo/daily_images/all_images_folders/widgets/images_folder_tile.dart';
import '../../lib/utils/datetime_utils.dart';
import '../utils/registration_utils.dart' as RegistrationUtils;

///
/// Using the given [tester] to enter to the right menu according to the given [key]
///
Future<void> enterToSpecificArrangementTypeByKey(
    {WidgetTester tester, String key}) async {
  final Finder wantedButton = find.byKey(Key(key));
  await tester.pumpAndSettle();
  await tester.tap(wantedButton);
  await tester.pumpAndSettle();
}

///
/// Using the given [tester] to enter to the Drive Arrangement page
///
Future<void> enterToDailyReportsPage({WidgetTester tester}) async {
  await enterToSpecificArrangementTypeByKey(
      tester: tester, key: DailyInfoKeys.DAILY_REPORTS_MENU);
}

///
/// Using the given [tester] to enter to the Drive Arrangement page
///
Future<void> enterToSpecificDailyReportsPage(
    {WidgetTester tester, String key}) async {
  await enterToSpecificArrangementTypeByKey(tester: tester, key: key);
}

///
/// Using the given [tester] to enter to the Drive Arrangement page
///
Future<void> enterToDriveArrangementPage({WidgetTester tester}) async {
  await enterToSpecificArrangementTypeByKey(
      tester: tester, key: DailyInfoKeys.DRIVE_MENU);
}

///
/// Using the given [tester] to enter to the Work Arrangement page
///
Future<void> enterToWorkArrangementPage({WidgetTester tester}) async {
  await enterToSpecificArrangementTypeByKey(
      tester: tester, key: DailyInfoKeys.WORK_MENU);
}

///
/// Using the given [tester] to enter to the ImagesFolder page
///
Future<void> enterToImagesFolderPage({WidgetTester tester}) async {
  await enterToSpecificArrangementTypeByKey(
      tester: tester, key: DailyInfoKeys.IMAGES_MENU);
}

///
/// Using given [tester] to enter to the add WorkArrangementPage
///
Future<void> enterAddArrangementPage({WidgetTester tester}) async {
  final Finder addArrangementButton =
      find.byKey(Key(DailyInfoKeys.ADD_ARRANGEMENT));
  await tester.tap(addArrangementButton);
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to enter to the add DriveArrangement
///
Future<void> enterAddDriveArrangementPage(
    {WidgetTester tester, DateTime date}) async {
  final Finder addArrangementButton =
      find.byKey(Key(DailyInfoKeys.ADD_ARRANGEMENT));
  await tester.tap(addArrangementButton);
  await tester.pumpAndSettle();
  final Finder datePicker =
      find.byKey(Key(DailyInfoKeys.DATE_PICKER_DRIVE_ARRANGEMENT));
  await tester.tap(datePicker);
  await chooseGivenDate(tester, date);
  await tester
      .tap(find.byKey(Key(DailyInfoKeys.OK_DATE_PICKER_DRIVE_ARRANGEMENT)));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to tap on the [WorkArrangementTile] with the date of [dateAsString] and was written by [editor]
///
Future<void> tapSpecificArrangementTile({
  WidgetTester tester,
  String dateAsString,
  String editor,
}) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key("${dateAsString}_$editor")));

  await tester.pumpAndSettle();
}

///
/// Using [tester] to get to certain mode - delete or edit arrangement, in a drive or work arrangement
///
Future<void> tapAndEnterModeForArrangement({
  WidgetTester tester,
  String dateAsString,
  String editor,
  IconData iconToFind,
}) async {
  final Finder iconButton = find.byIcon(iconToFind);

  await tapSpecificArrangementTile(
    tester: tester,
    dateAsString: dateAsString,
    editor: editor,
  );

  await tester.pumpAndSettle();
  await tester.ensureVisible(iconButton);
  await tester.pumpAndSettle();
  await tester.tap(iconButton);
  await tester.pumpAndSettle();
}

///
/// Using [tester] to get into edit mode for a Working Arrangement of a given date [dateAsString] and written by [editor]
///
Future<void> tapAndEnterEditModeWorkArrangement({
  WidgetTester tester,
  String dateAsString,
  String editor,
}) async {
  await tapAndEnterModeForArrangement(
    tester: tester,
    dateAsString: dateAsString,
    editor: editor,
    iconToFind: Icons.edit,
  );
}

///
/// Using [tester] to get into edit mode for a Drive Arrangement of a given date [dateAsString] and written by [editor]
///
Future<void> tapAndEnterEditModeDriveArrangement({
  WidgetTester tester,
  String dateAsString,
  String editor,
}) async {
  await tapAndEnterModeForArrangement(
    tester: tester,
    dateAsString: dateAsString,
    editor: editor,
    iconToFind: Icons.edit,
  );
}

///
/// Using [tester] to delete a Arrangement of a given date [dateAsString] and written by [editor]
///
Future<void> tapAndDeleteArrangement({
  WidgetTester tester,
  String dateAsString,
  String editor,
}) async {
  await tapAndEnterModeForArrangement(
    tester: tester,
    dateAsString: dateAsString,
    editor: editor,
    iconToFind: Icons.delete,
  );
  await tester.pumpAndSettle();
  final Finder sureDelete =
      find.byKey(Key(DailyInfoKeys.SURE_DELETE_ARRANGEMENT));
  await tester.tap(sureDelete);
  await tester.pumpAndSettle();
}

///
/// Using the given [tester] to fill the work arrangement form with the given [date] and given [info]
///
Future<void> fillArrangement(
    {WidgetTester tester,
    DateTime date,
    String info,
    String dateKey,
    String infoKey}) async {
  final Finder datePickerFinder = find.byKey(Key(dateKey));
  final Finder infoFinder = find.byKey(Key(infoKey));
  if (date != null) {
    await tester.ensureVisible(datePickerFinder);
    await tester.pumpAndSettle();
    await tester.tap(datePickerFinder);
    await chooseGivenDate(tester, date);
  }
  if (info != null) {
    await tester.ensureVisible(infoFinder);
    await tester.pumpAndSettle();
    await tester.tap(infoFinder);
    await tester.pumpAndSettle();
    await tester.enterText(infoFinder, info);
    await tester.pumpAndSettle();
  }
  await tester.pumpAndSettle();
}

///
/// Using [tester] to choose given [date] in date Picker
///
Future chooseGivenDate(WidgetTester tester, DateTime date) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text(date.day.toString()));
  await tester.pumpAndSettle();
  await tester.tap(find.text("אישור"));
  await tester.pumpAndSettle();
}

///
/// Using [tester] to submit the details in the Work Arrangement form
///
Future<void> submitArrangementForm(
    {WidgetTester tester, String keySubmit}) async {
  final Finder submitBtn = find.byKey(Key(keySubmit));
  await tester.ensureVisible(submitBtn);
  await tester.pumpAndSettle();
  await tester.tap(submitBtn);
  await tester.pumpAndSettle();
}

/// Using [tester] to add a Folder with the given
Future<void> addImageFolder({WidgetTester tester, DateTime date}) async {
  final Finder addBtn = find.byKey(Key(DailyInfoKeys.ADD_MAP_FOLDER));
  await tester.tap(addBtn);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.DATE_PICKER_MAP_FOLDER)));
  await tester.pumpAndSettle();
  await chooseGivenDate(tester, date);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.OK_DATE_PICKER_MAP_FOLDER)));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to tap on the [ImageFolderTile] with the date of [dateAsString] and was written by [editor]
///
Future<void> tapSpecificImageFolderTile({
  WidgetTester tester,
  String dateAsString,
}) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text(dateAsString));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to tap on the [ImageFolderTile] with the date of [dateAsString] and was written by [editor]
///
Future<void> enterSpecificFolderPage({
  WidgetTester tester,
  String dateAsString,
}) async {
  await tapSpecificImageFolderTile(tester: tester, dateAsString: dateAsString);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(StyleConstants.ICON_DAILY_IMAGES));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to tap on the [ImageFolderTile] with the date of [dateAsString] and was written by [editor]
///
Future<void> addImageToFolderWithCamera({
  WidgetTester tester,
  String dateAsString,
  String imageName,
}) async {
  await enterSpecificFolderPage(tester: tester, dateAsString: dateAsString);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.photo_camera));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.photo_camera));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.done));
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
  final Finder nameField = find.byKey(Key(DailyInfoKeys.ADD_IMAGE_FORM_NAME));
  await tester.ensureVisible(nameField);
  await tester.pumpAndSettle();
  await tester.tap(nameField);
  await tester.pumpAndSettle();
  await tester.enterText(nameField, imageName);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.ADD_IMAGE_FORM_SUBMIT)));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to edit name of a Image folder
///
Future<void> editNameOfImage({
  WidgetTester tester,
  String newName,
}) async {
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();
  final Finder nameField = find.byKey(Key(DailyInfoKeys.ADD_IMAGE_FORM_NAME));
  await tester.ensureVisible(nameField);
  await tester.pumpAndSettle();
  await tester.tap(nameField);
  await tester.pumpAndSettle();
  await tester.enterText(nameField, newName);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.ADD_IMAGE_FORM_SUBMIT)));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to edit name of a Image folder
///
Future<void> deleteImage({
  WidgetTester tester,
  String imageName,
}) async {
  await tester.tap(find.byIcon(Icons.delete));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.SURE_DELETE_IMAGE)));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to edit name of a Image folder
///
Future<void> editNameOfImageFolder({
  WidgetTester tester,
  String oldDateAsString,
  DateTime newDate,
}) async {
  await tapSpecificImageFolderTile(
      tester: tester, dateAsString: oldDateAsString);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.DATE_PICKER_MAP_FOLDER)));
  await tester.pumpAndSettle();
  await chooseGivenDate(tester, newDate);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.OK_DATE_PICKER_MAP_FOLDER)));
  await tester.pumpAndSettle();
}

///
/// Using given [tester] to edit name of a Image folder
///
Future<void> deleteImageFolder(
    {WidgetTester tester, String dateAsString}) async {
  await tapSpecificImageFolderTile(tester: tester, dateAsString: dateAsString);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.delete));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(DailyInfoKeys.SURE_DELETE_MAP_FOLDER)));
  await tester.pumpAndSettle();
}

Future<void> submitReport({WidgetTester tester}) async {
  final gesture =
      await tester.startGesture(Offset(0, 600)); //Position of the scrollview
  await tester.pumpAndSettle();
  await gesture.moveBy(Offset(0, -600)); //How much to scroll by
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
  final Finder buttonFinder = find.widgetWithText(RaisedButton, 'שמור');
  final RaisedButton button =
      buttonFinder.evaluate().first.widget as RaisedButton;
  button.onPressed();
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
}

Future<void> tapSpecificReport(
    {WidgetTester tester, String timeOfReport, String editor}) async {
  final Finder testPlot = find.text(
      "${dateToString(DateTime.now().toLocal())} - ${RegistrationUtils.ADMIN_NAME ?? "?"}");
  await tester.pumpAndSettle();
  await tester.tap(testPlot);
  await tester.pumpAndSettle();
}

Future<void> enterEditReportMode({WidgetTester tester}) async {
  final Finder editButton = find.byIcon(Icons.edit);
  await tester.tap(editButton);
  await tester.pumpAndSettle();
}

Future<void> fillReport({
  WidgetTester tester,
  Map<String, dynamic> report,
}) async {
  for (String key in report.keys) {
    final Finder currentField = find.byKey(Key(key));
    await tester.tap(currentField);
    await tester.enterText(currentField, (report[key] as String));
    await tester.pumpAndSettle();
  }
}

Future<void> deleteSpecificReport(
    {WidgetTester tester, String authorName, DateTime reportTime}) async {
  if (reportTime == null) {
    reportTime = DateTime.now();
  }
  await tapSpecificReport(
    tester: tester,
    timeOfReport: dateToString(reportTime),
    editor: authorName,
  );
  await tester.pumpAndSettle();
  final Finder deleteButton = find.byIcon(Icons.delete);
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();
  final Finder sureDeleteButton = find.byKey(
    Key(DailyInfoKeys.SURE_TO_DELETE_REPORT),
  );
  await tester.tap(sureDeleteButton);
  await tester.pumpAndSettle();
}
