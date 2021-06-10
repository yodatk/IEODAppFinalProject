import 'package:IEODApp/screens/managesSiteAndPlots/all_strips_screen/controllers/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../logger.dart' as Logger;
import '../../../../models/plot.dart';
import '../../../../models/strip.dart';
import '../../../../models/stripStatus.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import 'strip_tile_list.dart';

///
/// List of [Strip] by status, represents as an Expendable List.
///
class StatusStripListTile extends HookWidget {
  ///
  /// status of all strips in this [Strip] list
  ///
  final StripStatus status;

  ///
  /// [Plot] that all of those [Strip] belong to
  ///
  final Plot plot;

  StatusStripListTile({@required this.status, @required this.plot});

  ///
  /// Get the matching stream according to the given [status]
  ///
  AutoDisposeStreamProviderFamily<List<Strip>, String> getProviderByStatus() {
    switch (status) {
      case StripStatus.NONE:
        return noneStatusStrips;
      case StripStatus.IN_FIRST:
        return inFirstStatusStrips;
      case StripStatus.FIRST_DONE:
        return firstDoneStatusStrips;
      case StripStatus.IN_SECOND:
        return inSecondStatusStrips;
      case StripStatus.SECOND_DONE:
        return secondDoneStatusStrips;
      case StripStatus.IN_REVIEW:
        return inReviewStatusStrips;
      case StripStatus.FINISHED:
        return finishedStatusStrips;
      default:
        Logger.error("should not Happen!!!");
        return noneStatusStrips;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(allStripsViewModel);
    final stripStreamValue = useProvider(getProviderByStatus()(this.plot.id));
    return stripStreamValue.when(
      data: (List<Strip> strips) {
        return ValueListenableBuilder(
          valueListenable: viewModel.screenUtils.query,
          builder: (BuildContext context, String query, Widget child) {
            final filteredStrips = query == null || query.isEmpty
                ? strips
                : strips.where((strip) => strip.name.contains(query)).toList();
            filteredStrips.sort((s1, s2) => s1.compareTo(s2));
            if (filteredStrips.isEmpty) {
              return child;
            } else {
              final expanded = ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredStrips.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    return StripListTile(filteredStrips[index]);
                  },
                ),
              );
              return getRightExpansion(context, filteredStrips, expanded);
            }
          },
          child: const SizedBox.shrink(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: printAndShowErrorWidget,
    );
  }

  ///
  /// Get the List of [Strip] tiles, or a message of an empty list.
  ///
  Widget getRightExpansion(
      BuildContext context, List<Strip> docs, Widget expanded) {
    final plotTitle = Text(
      'סטריפים',
      style: Theme.of(context).textTheme.headline6,
    );
    List<Widget> finalChildrenList = [
      plotTitle,
      if (docs.isNotEmpty) expanded,
      if (docs.isEmpty) const Text('כרגע אין סטריפים עם סטטוס זה'),
    ];

    return Container(
      child: ExpansionTile(
        key: UniqueKey(),
        title: Text(
          generateTitleFromStripStatus(this.status),
          style: Theme.of(context).textTheme.headline5,
        ),
        leading: Icon(convertStatusToIcon(
          this.status,
        )),
        children: finalChildrenList,
      ),
    );
  }
}
