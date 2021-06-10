import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/style_constants.dart' as StyleConstants;
import '../../../../models/project.dart';
import '../controllers/controllers.dart';

///
/// Single project to choose from the Project grid [Widget]
///
class ProjectTile extends HookWidget {
  ///
  /// [Project] to choose
  ///
  final Project project;

  ProjectTile(this.project);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(chooseProjectViewModelProvider);
    return GestureDetector(
      onTap: () async {
        await viewModel.changeProject(project.id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: FadeInImage(
            placeholder: AssetImage(StyleConstants.PLACE_HOLDER_IMAGE),
            image: project.imageUrl != null && project.imageUrl.isNotEmpty
                ? CachedNetworkImageProvider(project.imageUrl)
                    as ImageProvider<Object>
                : AssetImage(StyleConstants.ICON_IMAGE_PATH_PNG),
            fit: BoxFit.fitWidth,
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                project.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
