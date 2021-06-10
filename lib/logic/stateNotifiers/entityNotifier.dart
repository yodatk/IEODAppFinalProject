import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../logger.dart' as Logger;
import '../../models/entity.dart';

///
/// [StateNotifier] Controller for the current [Entity] the current user is browsing
///
class EntityController<T extends Entity> extends StateNotifier<T> {
  ///
  /// subscription for the [Stream] of the wanted [T]
  ///
  StreamSubscription<T> _currentEntityChanges;

  Stream<T> Function(String id) streamFunction;

  EntityController({@required String id, @required this.streamFunction})
      : super(null) {
    reset(id);
  }

  ///
  /// Return the current [T] from stream
  ///
  T read() {
    return state;
  }

  ///
  /// set current [T] to be [element]
  ///
  Future<void> set(T element) async {
    state = element;
  }

  String getId() => state?.id;

  ///
  /// Reset Stream to the [T] with the given [id]
  ///
  Future<void> reset(String id) async {
    if (id == null) {
      await _currentEntityChanges?.cancel();
      state = null;
    } else {
      final stream = this.streamFunction(id);
      await _currentEntityChanges?.cancel();
      _currentEntityChanges = stream.listen((entity) {
        state = entity;
      }, onError: (error, stack) {
        if (error.toString().contains("permission-denied")) {
          // ignore this kind of error
        } else {
          Logger.warning("Unexpected Error:\n ${error.toString()}");
        }
        state = null;
      });
    }
  }

  ///
  /// Canceling current subscription to [T] stream
  ///
  Future<void> cancel() async => _currentEntityChanges?.pause();

  @override
  void dispose() {
    _currentEntityChanges?.cancel();
    super.dispose();
  }
}
