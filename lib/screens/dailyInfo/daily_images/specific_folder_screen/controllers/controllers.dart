import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

import '../../../../../constants/constants.dart' as Constants;
import '../../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../../controllers/state_providers/screen_utils.dart';
import '../../../../../logger.dart' as Logger;
import '../../../../../logic/ProjectHandler.dart';
import '../../../../../logic/dailyInfoHandler.dart';
import '../../../../../models/image_folder.dart';
import '../../../../../models/image_reference.dart';
import '../../../../../widgets/image_picker_and_shower.dart';
import '../../../constants/keys.dart' as Keys;

///
/// ViewModel class for the all images folders screen
///
final specificFolderScreenViewModel =
    Provider.autoDispose<SpecificFolderViewModel>(
        (ref) => SpecificFolderViewModel());

///
/// Stream Provider bto get all Images of a given folder
///
final allImagesOfFolderStream = StreamProvider.autoDispose
    .family<List<ImageReference>, ImageFolder>((ref, folder) =>
        DailyInfoHandler().allImageReferencesStream(
            ProjectHandler().getCurrentProjectId(), folder.id));

///
/// View Model class for the SpecificFolderScreen
///
class SpecificFolderViewModel {
  ///
  /// ScreenUtils for the Specific Folder Screen
  ///
  final screenUtils = ScreenUtilsController();

  ///
  /// chosen image for uplaod
  ///
  File chosenImage;

  ///
  /// Changing the chosen image to the given [chosen] image
  ///
  void setChosenImage(File chosen) => chosenImage = chosen;

  ///
  /// adding image form key
  ///
  final addImageFormKey = GlobalKey<FormBuilderState>();

  ///
  /// trying to add Image for the for the current folder
  ///
  void addImage({
    @required BuildContext context,
    @required File image,
    @required String name,
    @required ImageFolder folder,
  }) async {
    this.screenUtils.isLoading.value = true;
    final imageReferenceToAdd = ImageReference(name: name);
    final msg = await DailyInfoHandler().uploadImageToFolder(
        folder: folder, toUpdate: imageReferenceToAdd, imageToUpload: image);
    this.screenUtils.isLoading.value = false;
    if (msg != null) {
      this
          .screenUtils
          .showOnSnackBar(msg: msg, successMsg: "התמונה נשמרה בהצלחה");
    }
  }

  ///
  /// updates the name of the image from the [updatedRef] image
  ///
  void updateImageName({
    @required BuildContext context,
    @required ImageReference updatedRef,
    @required ImageFolder folder,
  }) async {
    this.screenUtils.isLoading.value = true;

    final msg = await DailyInfoHandler()
        .updatingSingleReference(folder: folder, refToUpdate: updatedRef);
    this.screenUtils.isLoading.value = false;
    this
        .screenUtils
        .showOnSnackBar(msg: msg, successMsg: "התמונה נערכה בהצלחה");
  }

  ///
  /// delete the given image [toDelete] from the given [folder]
  ///
  void deleteImage({
    @required BuildContext context,
    @required ImageReference toDelete,
    @required ImageFolder folder,
  }) async {
    this.screenUtils.isLoading.value = true;

    final msg = await DailyInfoHandler()
        .deleteImage(folder: folder, toDelete: toDelete);
    this.screenUtils.isLoading.value = false;
    this
        .screenUtils
        .showOnSnackBar(msg: msg, successMsg: "התמונה נמחקה בהצלחה");
  }

  ///
  /// opening the add image dialog
  ///
  openAddImageDialog(BuildContext context, List<ImageReference> allImages,
      ImageFolder folder) async {
    Alert(
        context: context,
        title: "הוספת תמונה",
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormBuilder(
                key: addImageFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ImagePickerAndShower(setChosenImage),
                    const SizedBox(
                      height: 10,
                    ),
                    FormBuilderTextField(
                      key: const Key(Keys.ADD_IMAGE_FORM_NAME),
                      name: Constants.IMAGE_REF_NAME,
                      decoration:
                          const InputDecoration(labelText: " שם התמונה "),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          context,
                          errorText: 'שדה זה הינו חובה להוספת תמונה',
                        ),
                        (value) {
                          return allImages
                                  .any((element) => element.name == value)
                              ? "קיימת תמונה עם שם זה בתיקייה זו"
                              : null;
                        },
                        (value) => value == null || value.trim().isEmpty
                            ? "לא ניתן לשים שם תמונה ללא אותיות"
                            : null,
                        (value) =>
                            chosenImage == null ? "לא נבחרה תמונה" : null,
                      ]),
                      valueTransformer: (val) => val == null ? "" : val.trim(),
                    ),
                    //ImagePi
                  ],
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            key: Key(Keys.ADD_IMAGE_FORM_SUBMIT),
            onPressed: () {
              final name = addImageFormKey.currentState
                  .fields[Constants.IMAGE_REF_NAME].value as String;
              FocusScope.of(context).unfocus();

              if (addImageFormKey.currentState.saveAndValidate()) {
                Navigator.of(context).pop();

                addImage(
                  context: context,
                  name: name,
                  image: chosenImage,
                  folder: folder,
                );
              }
            },
            child: Text(
              "הוסף תמונה",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  ///
  /// show delete Image from folder dilog
  ///
  void showDeleteImageDialog(
      BuildContext context, ImageReference image, ImageFolder folder) {
    Alert(
      context: this.screenUtils.scaffoldKey.currentContext,
      type: AlertType.warning,
      title: "מחיקת תמונה",
      desc: 'האם אתה בטוח שאתה רוצה למחוק את התמונה "${image.name}" ?',
      buttons: [
        DialogButton(
          key: Key(Keys.SURE_DELETE_IMAGE),
          child: Text(
            "כן",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            this.deleteImage(
              context: this.screenUtils.scaffoldKey.currentContext,
              toDelete: image,
              folder: folder,
            );
          },
          width: 60,
          color: Theme.of(context).errorColor,
        ),
        DialogButton(
          key: Key(Keys.CANCEL_DELETE_IMAGE),
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

  ///
  /// show the edit name of image dialog
  ///
  void showEditNameOfImageDialog(BuildContext context, ImageReference image,
      List<ImageReference> allImages, ImageFolder folder) async {
    final _formKey = GlobalKey<FormBuilderState>();

    Alert(
        context: this.screenUtils.scaffoldKey.currentContext,
        title: "עריכת תמונה",
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormBuilder(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FormBuilderTextField(
                      key: const Key(Keys.ADD_IMAGE_FORM_NAME),
                      name: Constants.IMAGE_REF_NAME,
                      initialValue: image.name,
                      decoration: const InputDecoration(
                          icon: const Icon(StyleConstants.ICON_DAILY_IMAGES),
                          labelText: " שם התמונה "),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          context,
                          errorText: 'שדה זה הינו חובה להוספת תמונה',
                        ),
                        (value) =>
                            allImages.any((element) => element.name == value)
                                ? "קיימת תמונה עם שם זה בתיקייה זו"
                                : null,
                        (value) => value == null || value.trim().isEmpty
                            ? "לא ניתן לשים שם תמונה ללא אותיות"
                            : null,
                      ]),
                      valueTransformer: (val) => val == null ? "" : val.trim(),
                    ),
                    //ImagePi
                  ],
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            key: Key(Keys.ADD_IMAGE_FORM_SUBMIT),
            onPressed: () {
              final name = _formKey.currentState
                  .fields[Constants.IMAGE_REF_NAME].value as String;

              FocusScope.of(context).unfocus();

              if (_formKey.currentState.saveAndValidate()) {
                final imageCopy = image.clone();
                imageCopy.name = name;
                Navigator.of(context).pop();
                this.updateImageName(
                  context: this.screenUtils.scaffoldKey.currentContext,
                  updatedRef: imageCopy,
                  folder: folder,
                );
              }
            },
            child: Text(
              "שמור",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  ///
  /// sharing the given image to
  ///
  void sharePictureFunction(BuildContext context, ImageReference image) async {
    try {
      this.screenUtils.isLoading.value = true;
      var response = await get(image.imageUrl);
      final documentDirectory = (await getExternalStorageDirectory()).path;
      final String docPath = '$documentDirectory/${image.name}.jpg';
      File imgFile = new File(docPath);
      imgFile.writeAsBytesSync(response.bodyBytes);
      Share.shareFiles([docPath]);
      this.screenUtils.isLoading.value = false;
    } catch (ignored, stack) {
      Logger.error(ignored.toString());
      Logger.error(stack.toString());
    } finally {
      this.screenUtils.isLoading.value = false;
    }
  }
}
