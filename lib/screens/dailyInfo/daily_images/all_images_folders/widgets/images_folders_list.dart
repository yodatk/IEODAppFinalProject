import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../logic/EmployeeHandler.dart';
import '../../../../../models/image_folder.dart';
import '../../../../../models/permission.dart';
import '../../../../../utils/datetime_utils.dart';
import '../../../../../widgets/loading_widget.dart';
import '../../../../../widgets/unexpected_error_widget.dart';
import '../../../constants/keys.dart' as Keys;
import '../controllers/controllers.dart';
import 'images_folder_tile.dart';

///
/// List of All [ImageFolder] in the project as List Tiles
///
class ImageFolderList extends StatefulHookWidget {
  @override
  _ImageFolderListState createState() => _ImageFolderListState();
}

class _ImageFolderListState extends State<ImageFolderList> {
  ///
  /// List of all available ImageFolder (to avoid same date)
  ///
  List<ImageFolder> allFolders;

  @override
  Widget build(BuildContext context) {
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    final viewModel = useProvider(allImagesFoldersViewModel);
    final allFoldersStreamValue = useProvider(allFolderOfCurrentProjectStream);
    final isWithAdd = currentEmployee.isPermissionOk(Permission.MANAGER);
    List<Widget> withAdd = [
      SizedBox(
        width: 5,
      ),
      ValueListenableBuilder<bool>(
        valueListenable: viewModel.screenUtils.isLoading,
        child: const CircularProgressIndicator(),
        builder: (BuildContext context, bool isLoading, Widget child) =>
            isLoading
                ? child
                : RaisedButton(
                    key: Key(Keys.ADD_MAP_FOLDER),
                    onPressed: () =>
                        viewModel.showAddDialog(context, this.allFolders),
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(),
                    child: Icon(Icons.create_new_folder, color: Colors.white),
                  ),
      ),
      SizedBox(
        width: 5,
      ),
    ];
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      (isWithAdd ? 0.7 : 0.9),
                  child: FormBuilderDateTimePicker(
                    name: "Search",
                    inputType: InputType.date,
                    initialValue: viewModel.screenUtils.query.value,
                    locale: Localizations.localeOf(context),
                    onChanged: (value) =>
                        viewModel.screenUtils.query.value = value,
                    decoration: const InputDecoration(
                        labelText: "חיפוש תיקיות",
                        hintText: "חיפוש תיקיות",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                if (isWithAdd) ...withAdd,
              ],
            ),
            allFoldersStreamValue.when(
                data: (allFolders) {
                  this.allFolders = List<ImageFolder>.from(allFolders);
                  final filteredFolders = viewModel.screenUtils.query.value ==
                          null
                      ? this.allFolders
                      : this
                          .allFolders
                          .where((element) =>
                              element.date != null &&
                              dateToString(element.date).contains(dateToString(
                                  viewModel.screenUtils.query.value)))
                          .toList();

                  filteredFolders.sort((d1, d2) => d2.date.compareTo(d1.date));

                  return filteredFolders.isEmpty
                      ? Center(
                          child: Text("לא נמצאו תיקיות",
                              style: Theme.of(context).textTheme.headline6),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: filteredFolders.length,
                                  separatorBuilder: (context, index) =>
                                      Divider(),
                                  itemBuilder: (context, index) {
                                    return ImageFolderTile(
                                      imageFolder: filteredFolders[index],
                                      allFolders: this.allFolders,
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                },
                loading: loadingDataWidget,
                error: printAndShowErrorWidget),
          ],
        ),
      ),
    );
  }
}
