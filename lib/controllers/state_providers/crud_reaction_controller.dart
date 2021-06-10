import 'package:flutter/material.dart';
import '../../models/entity.dart';

class CrudFunctionProvider<T extends Entity> {
  final Future<void> Function({
    @required T toAdd,
    @required BuildContext context,
    @required String successMsg,
  }) addReaction;

  final Future<void> Function({
    @required T toEdit,
    @required BuildContext context,
    @required String successMsg,
  }) editReaction;

  final Future<void> Function({
    @required T toDelete,
    @required BuildContext context,
    @required String successMsg,
  }) deleteReaction;

  CrudFunctionProvider(this.addReaction,this.editReaction,this.deleteReaction);
}

