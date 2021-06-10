import 'package:IEODApp/screens/managesSiteAndPlots/all_strips_screen/controllers/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../models/permission.dart';
import '../../../../models/strip.dart';
import '../../../../widgets/permission_widgets/permission_widget.dart';
import 'edit_strip_form.dart';

///
/// Represents a given [Strip] as a [ListTile].
///
class StripListTile extends HookWidget {
  ///
  /// [Strip] to show
  ///
  final Strip strip;

  StripListTile(this.strip);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allStripsViewModel);

    return Center(
      child: PermissionWidget(
          permissionLevel: Permission.MANAGER,
          withPermission: ListTile(
            key: UniqueKey(),
            title: Text(
              strip.getTitle(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(strip.getSubs()),
            leading: IconButton(
              icon: Icon(StyleConstants.ICON_EDIT),
              tooltip: "ערוך סטריפ",
              onPressed: () {
                viewModel.editStripName(strip);
              },
            ),
            onTap: () {
              final dialog = Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                //this right here
                child: Stack(
                  children: [
                    EditStripForm(toEdit: this.strip),
                    Positioned(
                      right: 0.0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 14.0,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              showDialog(context: context, builder: (context) => dialog);
            },
            // children: children,
          )),
    );
  }
}
