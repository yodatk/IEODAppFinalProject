import 'package:flutter/foundation.dart';

import '../../../logic/EmployeeHandler.dart';
import '../../../logic/ProjectHandler.dart';
import '../../../logic/fieldHandler.dart';
import '../../../models/entity.dart';
import '../../Employee.dart';
import '../bricks/FunctionDropDownBrick.dart';
import '../bricks/ReadOnlyTextBrick.dart';
import '../bricks/parentBrick.dart';
import '../bricks/templateBrick.dart';
import 'Template.dart';

///
/// All entities that are possible to resolve in a readOnly field
///
enum SingleResolvedEntityEnum { PLOT, PROJECT }

///
/// All List of entities that ar possible to use in the DropList fields
///
enum ResolvedEntityListEnum { MECHANICAL_TEAM_LEADERS, ADMINS, EMPLOYEES }

///
/// Convert a given string to a [SingleResolvedEntityEnum]
///
SingleResolvedEntityEnum convertSingleResolvedEntityEnum(String toConvert) {
  return SingleResolvedEntityEnum.values
      .firstWhere((e) => describeEnum(e) == toConvert);
}

///
/// Convert a given string to a [ResolvedEntityListEnum]
///
ResolvedEntityListEnum convertResolvedEntityListEnum(String toConvert) {
  return ResolvedEntityListEnum.values
      .firstWhere((e) => describeEnum(e) == toConvert);
}

///
/// Class to fill automatically parts of the report if possible
///
class FunctionResolver {
  static final FunctionResolver _readOnlyResolver =
      FunctionResolver._internal();

  factory FunctionResolver() {
    return _readOnlyResolver;
  }

  ///
  /// Map to route an read only enum to the matching query function
  ///
  Map<SingleResolvedEntityEnum, Function> _singleEntityToResolveFunction;

  ///
  /// Map to route an drop list enum to the matching query function
  ///
  Map<ResolvedEntityListEnum, Function> _listEntityToResolveFunction;

  ///
  /// Caching results of read only fields to not call data base twice in one report
  ///
  Map<SingleResolvedEntityEnum, Entity> _singleCache;

  ///
  /// Caching results of droplist fields to not call data base twice in one report
  ///
  Map<ResolvedEntityListEnum, List<Entity>> _listCache;

  FunctionResolver._internal() {
    _singleEntityToResolveFunction = {
      SingleResolvedEntityEnum.PLOT: () => FieldHandler().readCurrentPlot(),
      SingleResolvedEntityEnum.PROJECT: () =>
          ProjectHandler().readCurrentProject(),
    };

    _listEntityToResolveFunction = {
      ResolvedEntityListEnum.MECHANICAL_TEAM_LEADERS: () =>
          getMechanicalTeamLeaders(),
      ResolvedEntityListEnum.ADMINS: () => getAllAdmins(),
      ResolvedEntityListEnum.EMPLOYEES: () => getAllEmployees(),
    };
  }

  Future<String> getSingleString(
      SingleResolvedEntityEnum singleEnum, fieldName) async {
    if (!_singleCache.containsKey(singleEnum) ||
        _singleCache[singleEnum] == null) {
      if (_singleEntityToResolveFunction.containsKey(singleEnum)) {
        Entity toCache =
            await _singleEntityToResolveFunction[singleEnum]() as Entity;
        _singleCache[singleEnum] = await toCache;
      } else {
        print("error in getSingleString");
        return null;
      }
    }
    Entity singleEntity = await _singleCache[singleEnum];
    String singleString = await singleEntity.toJson()[fieldName] as String;
    return singleString;
  }

  Future<List<String>> getStringList(
      ResolvedEntityListEnum listEnum, fieldName) async {
    if (!_listCache.containsKey(listEnum) || _listCache[listEnum] == null) {
      if (_listEntityToResolveFunction.containsKey(listEnum)) {
        List<Entity> toCache =
            await _listEntityToResolveFunction[listEnum]() as List<Entity>;
        _listCache[listEnum] = await toCache;
      } else {
        print("error in getStringList");
        return null;
      }
    }
    List<Entity> entityList = await _listCache[listEnum];
    List<String> stringList = await entityList
        .map((entity) => entity.toJson()[fieldName] as String)
        .toList();
    return stringList;
  }

  Future<List<Employee>> getMechanicalTeamLeaders() async {
    List<Employee> managers =
        await EmployeeHandler().getAllManagersFromCurrentProject();
    return managers;
  }

  Future<List<Employee>> getAllAdmins() async {
    List<Employee> admins =
        await EmployeeHandler().getAllAdminsFromCurrentProject();
    return admins;
  }

  Future<List<Employee>> getAllEmployees() async {
    List<Employee> employees =
        await EmployeeHandler().getAllEmployeesFromCurrentProjectAsFuture();
    return employees;
  }

  void flushCaches() {
    _singleCache = Map<SingleResolvedEntityEnum, Entity>();
    _listCache = Map<ResolvedEntityListEnum, List<Entity>>();
  }

  Future<void> resolveFunctionDerivedData(Template template) async {
    flushCaches();
    for (TemplateBrick brick in template.templateBricks) {
      await resolve(brick);
    }
    flushCaches();
  }

  ///
  /// Get a [TemplateBrick] and recursively fill it with data it can resolve automatically
  ///
  Future<void> resolve(TemplateBrick brick) async {
    if (brick is ReadOnlyTextBrick) {
      brick.text =
          await getSingleString(brick.singleEntityEnum, brick.fieldName);
    } else if (brick is FunctionDropDownBrick) {
      brick.choices =
          await getStringList(brick.listEntityEnum, brick.fieldName);
    } else if (brick is ParentBrick) {
      for (TemplateBrick childBrick in brick.children) {
        await resolve(childBrick);
      }
    }
  }
}
