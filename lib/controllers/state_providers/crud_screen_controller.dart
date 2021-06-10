import 'package:flutter/material.dart';
import '../../models/entity.dart';

class CrudFunctionProvider<T extends Entity> {
  Future<void> Function({
    @required T toAdd,
    @required BuildContext context,
    @required String successMsg,
  }) addFunc;

  Future<void> Function({
    @required T toEdit,
    @required BuildContext context,
    @required String successMsg,
  }) editFunc;

  Future<void> Function({
    @required T toDelete,
    @required BuildContext context,
    @required String successMsg,
  }) deleteFunc;

  CrudFunctionProvider({
    @required this.addFunc,
    @required this.editFunc,
    @required this.deleteFunc,
  });
}

