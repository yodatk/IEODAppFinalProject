import '../../../models/entity.dart';
import 'package:flutter/foundation.dart';

///
/// Generic DAO class for [Entity] classes
///
abstract class EntityDAO<T extends Entity> {
  ///
  /// from json constructor for class of type [T]
  ///
  final T Function({
    @required String id,
    @required Map<String, dynamic> data,
  }) fromJson;

  ///
  /// Default constructor
  ///
  EntityDAO({
    this.fromJson,
  });

  ///
  /// Update details of [toUpdate] in the [currentProject] in the Database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> update({
    @required T toUpdate,
    @required Map<String, dynamic> data,
    @required String currentProjectId,
  });

  ///
  /// Update details of [toUpdate] in the [Project] with [currentProjectId] in the Database, overriding the details in database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> updateWithOverride(
      {@required String currentProjectId, @required T toUpdate});

  ///
  /// Delete [toDelete] from the [currentProject] in the Database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> deleteWithEntity({
    @required String currentProject,
    @required T toDelete,
  });

  ///
  /// Delete [toDeleteId] from the [currentProject] in the Database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> deleteWithId({
    @required String currentProject,
    @required String toDeleteId,
  });

  ///
  /// Get [T] according to given [id]
  /// if [currentProject] is null, search [collectionName] in root
  /// else search it in a [Project] with the given [currentProject] id
  ///
  Future<T> getById({
    @required String currentProject,
    @required String id,
  });

  ///
  /// Get [T] as Stream according to given [id]
  /// if [currentProject] is null, search [collectionName] in root
  /// else search it in a [Project] with the given [currentProject] id
  ///
  Stream<T> getByIdAsStream({
    @required String currentProject,
    @required String id,
  });

  ///
  /// In cases you need an id before writing to data base,
  /// this function will pre generate a [String] id for you.
  ///
  String preGenerateId({@required String projectId});

  ///
  /// Return a List of all [T] from a [Project] with the given [projectId]
  /// if [projectId] si null, try to query a collection named [collectionName] from the root
  ///
  Future<List<T>> allItemsAsList({@required String projectId});

  ///
  /// Return a List of all [T] from a [Project] with the given [projectId] which answers the predicate of [field] == [predicate]
  /// if [projectId] si null, try to query a collection named [collectionName] from the root
  ///
  Future<List<T>> allItemsAsListWithEqualsGivenField({
    @required String projectId,
    @required String field,
    @required dynamic predicate,
  });

  ///
  /// Get all [T] in collection as a [QuerySnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  Stream<List<T>> allItemsAsStream({@required String projectId});

  ///
  /// Get all [T] in collection as Stream
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  Stream<List<T>> allItemsFilteredByFieldsAsStream({
    @required String projectId,
    @required Map<String, dynamic> fields,
  });

  ///
  /// Get stream List of [T] if the entity give [arrayField] contains the given [value]
  ///
  Stream<List<T>> allItemsAsStreamWithArrayContainsClause(
      {@required String projectId, @required arrayField, @required value});

  ///
  /// Get stream List of [T] if the entity give [arrayField] contains the given [value]
  ///
  Stream<List<T>> allItemsAsStreamWithArrayContainsClauseAndIsEqual({
    @required String projectId,
    @required arrayField,
    @required value,
    @required Map<String, dynamic> isEqualFields,
  });

  ///
  /// Get future List of [T] if the entity give [arrayField] contains the given [value]
  ///
  Future<List<T>> allItemsAsListWithArrayContainsClause(
      {@required String projectId, @required arrayField, @required value});

  ///
  /// Get List of [T] if the entity give [arrayField] contains the given [value]
  ///
  Future<List<T>> allItemsAsListWithArrayContainsClauseAndIsEqual({
    @required String projectId,
    @required arrayField,
    @required value,
    @required Map<String, dynamic> isEqualFields,
  });



  ///
  /// Deletes all items in collection FOR TESTS PURPOSES ONLY.
  /// The function should work only if the DataService is on Test Env
  ///
  Future<String> deleteAllItemsForTestOnly(String projectId);
}
