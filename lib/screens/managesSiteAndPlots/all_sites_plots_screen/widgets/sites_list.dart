import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../controllers/snackbar_capable.dart';
import '../../../../controllers/state_providers/screen_utils.dart';
import '../../../../logger.dart' as Logger;
import '../../../../logic/EmployeeHandler.dart';
import '../../../../models/Employee.dart';
import '../../../../models/permission.dart';
import '../../../../models/plot.dart';
import '../../../../models/site.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/unexpected_error_widget.dart';
import '../controllers/controllers.dart';
import 'site_list_tile.dart';

///
/// List of all [Site] in project as Expendable List tiles
///
class SiteList extends StatefulHookWidget {
  final Key key;

  SiteList({this.key});

  @override
  _SiteListState createState() => _SiteListState();
}

class _SiteListState extends State<SiteList> with SnackBarCapable {
  ///
  /// all [Site] in this [Project]
  ///
  List<Site> allSites;

  ///
  /// filtering the [Plot] and [Site] list according to the given [newQuery] : only [Plot] that contain the [newQuery] in their name will show
  ///
  void filterSearchResults(
          ScreenUtilsControllerForList<String> screenUtils, String newQuery) =>
      screenUtils.query.value = newQuery;

  @override
  Widget build(BuildContext context) {
    final currentEmployee = useProvider(currentEmployeeProvider.state);
    final allSitesStreamValue = useProvider(allSitesStream);
    final allPlotsStreamValue = useProvider(allPlotsStream);
    final viewModel = useProvider(allSitesAndPlotViewModel);
    List<Widget> addButton = getAddButton(currentEmployee, context);
    final noPlotsFound = Center(
        child: Text(
      "לא נמצאו חלקות",
      style: Theme.of(context).textTheme.headline6,
    ));

    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        ((currentEmployee != null &&
                                currentEmployee
                                    .isPermissionOk(Permission.ADMIN))
                            ? 0.7
                            : 0.9),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        filterSearchResults(viewModel.screenUtils, value),
                    // refresh
                    decoration: const InputDecoration(
                        labelText: "חיפוש חלקות",
                        hintText: "חיפוש חלקות",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                ...addButton,
              ],
            ),
            allSitesStreamValue.when(
              data: (siteList) => allPlotsStreamValue.when(
                  data: (plotList) {
                    this.allSites = siteList;
                    return ValueListenableBuilder<String>(
                      valueListenable: viewModel.screenUtils.query,
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: noPlotsFound),
                      builder:
                          (BuildContext context, String query, Widget child) {
                        final filteredPlots = query.isEmpty
                            ? plotList
                            : plotList
                                .where((item) => (item.name != null &&
                                    item.name.contains(query)))
                                .toList();
                        if (siteList.isEmpty ||
                            (query.isNotEmpty && filteredPlots.isEmpty)) {
                          return child;
                        } else {
                          siteList.sort(
                              (Site s1, Site s2) => s1.name.compareTo(s2.name));
                          final siteToPlots = Map.fromIterable(siteList,
                              key: (site) => site.id as String,
                              value: (_) => <Plot>[]);
                          filteredPlots.forEach((plot) {
                            final siteId = plot.siteId;
                            if (!siteToPlots.containsKey(siteId)) {
                              Logger.info(
                                  "Orphaned Plot: ${plot.id} - Site Id: $siteId");
                              // siteToPlots[siteId] = <QueryDocumentSnapshot>[];
                            } else {
                              siteToPlots[siteId].add(plot);
                            }
                          });
                          var filteredSites = query.isNotEmpty
                              ? siteList.where(
                                  (site) => siteToPlots[site.id].isNotEmpty)
                              : siteList;
                          final List<Widget> siteTiles = filteredSites
                              .map((site) => SiteListTile(
                                    site: site,
                                    plots: siteToPlots[site.id],
                                    currentUser: currentEmployee,
                                  ))
                              .toList();
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                            ),
                            child: siteTiles.isEmpty
                                ? noPlotsFound
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: siteTiles,
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        }
                      },
                    );
                  },
                  loading: loadingDataWidget,
                  error: printAndShowErrorWidget),
              loading: () => const CircularProgressIndicator(),
              error: printAndShowErrorWidget,
            )
          ],
        ),
      ),
    );
  }

  ///
  /// shows/not shows the add Site button according to the permission of the current user
  ///
  List<Widget> getAddButton(Employee currentUser, BuildContext context) {
    final viewModel = context.read(allSitesAndPlotViewModel);
    return currentUser == null || !(currentUser.permission == Permission.ADMIN)
        ? []
        : [
            ValueListenableBuilder<bool>(
              valueListenable: viewModel.screenUtils.isLoading,
              builder: (BuildContext context, bool value, Widget child) =>
                  value ? const CircularProgressIndicator() : child,
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                shape: CircleBorder(),
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  viewModel.openAddSiteDialog(context, allSites);
                },
              ),
            ),
          ];
  }
}
