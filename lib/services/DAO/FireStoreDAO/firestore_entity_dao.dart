import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../logger.dart' as Logger;
import '../../../models/entity.dart';
import '../../services_firebase/firebase_data_service.dart';
import '../interfacesDAO/entity_dao.dart';

///
/// Generic DAO class for [Entity] classes with FireStore
///
abstract class FireStoreEntityDAO<T extends Entity> implements EntityDAO<T> {
  ///
  /// name of the collection in firebase
  ///
  final String collectionName;

  ///
  /// [WriteBatch] to use when updating the data base
  ///
  WriteBatch writeBatch;

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
  FireStoreEntityDAO({
    @required this.collectionName,
    this.fromJson,
  });

  ///
  /// Resetting  the current [WriteBatch]
  ///
  void getNewBatch() {
    this.writeBatch = FirebaseFirestore.instance.batch();
  }

  ///
  /// Commit current changes to database
  ///
  Future<void> commit() async {
    await this.writeBatch.commit();
  }

  ///
  /// Update details of [toUpdate] in the [currentProject] in the Database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> update({
    @required T toUpdate,
    @required Map<String, dynamic> data,
    @required String currentProjectId,
  }) async {
    try {
      getNewBatch();
      await updateLogic(toUpdate, data, currentProjectId);
      await commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "'update' in $collectionName");
    }
  }

  String preGenerateId({@required String projectId}) =>
      getCollectionReference(projectId: projectId).doc().id;

  ///
  /// inner logic of update for more flexible override
  ///
  Future<void> updateLogic(
    T toUpdate,
    Map<String, dynamic> data,
    String currentProjectId,
  ) async {
    final collectionRef = getCollectionReference(projectId: currentProjectId);
    DocumentReference docRef =
        getDocReferenceForUpdate(toUpdate, collectionRef);
    writeBatch.update(docRef, data);
  }

  ///
  /// Update details of [toUpdate] in the [Project] with [currentProjectId] in the Database, overriding the details in database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> updateWithOverride(
      {@required String currentProjectId, @required T toUpdate}) async {
    try {
      getNewBatch();
      await updateWithOverrideLogic(toUpdate, currentProjectId);
      commit();
      return "";
    } catch (error) {
      return handleGeneralError(
          error, "'updateWithOverride' in $collectionName");
    }
  }

  ///
  /// inner logic of override update for more flexible override
  ///
  Future<void> updateWithOverrideLogic(
      T toUpdate, String currentProject) async {
    final collectionRef = getCollectionReference(projectId: currentProject);
    DocumentReference docRef =
        getDocReferenceForUpdate(toUpdate, collectionRef);
    Map<String, dynamic> entry = toUpdate.toJson();
    writeBatch.set(docRef, entry);
  }

  ///
  /// Get correct document reference in collection [collectionRef] according to given details in [toUpdate]
  ///
  @protected
  DocumentReference getDocReferenceForUpdate(
      T toUpdate, CollectionReference collectionRef) {
    DocumentReference docRef;
    if (toUpdate.id == null || toUpdate.id == "") {
      // new document
      docRef = collectionRef.doc();
    } else {
      // exiting document
      toUpdate.timeModified = DateTime.now();
      docRef = collectionRef.doc(toUpdate.id);
    }
    return docRef;
  }

  ///
  /// Delete [toDelete] from the [currentProject] in the Database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> deleteWithEntity({
    @required String currentProject,
    @required T toDelete,
  }) async {
    try {
      getNewBatch();
      await deleteLogicWithEntity(currentProject, toDelete);
      await commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "'delete' in $collectionName");
    }
  }

  ///
  /// Delete [toDeleteId] from the [currentProject] in the Database
  /// if something went wrong in the update, will return a string with the error details.
  /// if update was successful , will return empty string
  ///
  Future<String> deleteWithId({
    @required String currentProject,
    @required String toDeleteId,
  }) async {
    try {
      getNewBatch();
      await deleteLogic(currentProject, toDeleteId);
      await commit();
      return "";
    } catch (error) {
      return handleGeneralError(error, "'delete' in $collectionName");
    }
  }

  ///
  /// inner logic of the delete function, in order to have a more generic way of overriding(for cascade delete handling and so on
  ///
  Future<void> deleteLogic(String currentProject, String toDeleteId) async {
    final docRef =
        getCollectionReference(projectId: currentProject).doc(toDeleteId);
    writeBatch.delete(docRef);
  }

  ///
  /// inner logic of the delete function, in order to have a more generic way of overriding(for cascade delete handling and so on
  ///
  Future<void> deleteLogicWithEntity(String currentProject, T toDelete) async {
    deleteLogic(currentProject, toDelete.id);
  }

  ///
  /// Get [T] according to given [id]
  /// if [currentProject] is null, search [collectionName] in root
  /// else search it in a [Project] with the given [currentProject] id
  ///
  Future<T> getById({
    @required String currentProject,
    @required String id,
  }) async {
    final doc =
        await getByIdAsDocumentReference(currentProject: currentProject, id: id)
            .get();
    return fromJson(id: doc.id, data: doc.data());
  }

  ///
  /// Get [T] as [DocumentSnapshot] according to given [id]
  /// if [currentProject] is null, search [collectionName] in root
  /// else search it in a [Project] with the given [currentProject] id
  ///
  @protected
  DocumentReference getByIdAsDocumentReference({
    @required String currentProject,
    @required String id,
  }) {
    return getCollectionReference(projectId: currentProject).doc(id);
  }

  ///
  /// Get [T] as Stream of [DocumentSnapshot] according to given [id]
  /// if [currentProject] is null, search [collectionName] in root
  /// else search it in a [Project] with the given [currentProject] id

  @protected
  Stream<DocumentSnapshot> getByIdAsDocumentSnapShotStream({
    @required String currentProject,
    @required String id,
  }) {
    CollectionReference collection =
        getCollectionReference(projectId: currentProject);
    return collection.doc(id).snapshots();
  }

  ///
  /// Get [T] as Stream of [DocumentSnapshot] according to given [id]
  /// if [currentProject] is null, search [collectionName] in root
  /// else search it in a [Project] with the given [currentProject] id
  ///
  Stream<T> getByIdAsStream({
    @required String currentProject,
    @required String id,
  }) {
    CollectionReference collection =
        getCollectionReference(projectId: currentProject);
    return collection
        .doc(id)
        .snapshots()
        .map((doc) => fromJson(id: doc.id, data: doc.data()));
  }

  ///
  /// Return a List of all [T] from a [Project] with the given [projectId]
  /// if [projectId] si null, try to query a collection named [collectionName] from the root
  ///
  Future<List<T>> allItemsAsList({@required String projectId}) async {
    final docs =
        await this.allItemsAsDocumentSnapshotList(projectId: projectId);
    return docs.map((e) => this.fromJson(id: e.id, data: e.data())).toList();
  }

  ///
  /// Return a List of all [T] as [DocumentSnapshot] from a [Project] with the given [projectId]
  /// if [projectId] si null, try to query a collection named [collectionName] from the root

  @protected
  Future<List<DocumentSnapshot>> allItemsAsDocumentSnapshotList(
      {@required String projectId}) async {
    QuerySnapshot temp =
        await getCollectionReference(projectId: projectId).get();
    return temp.docs;
  }

  ///
  /// Return a List of all [T] from a [Project] with the given [projectId] which answers the predicate of [field] == [predicate]
  /// if [projectId] si null, try to query a collection named [collectionName] from the root
  ///
  Future<List<T>> allItemsAsListWithEqualsGivenField({
    @required String projectId,
    @required String field,
    @required dynamic predicate,
  }) async {
    List<DocumentSnapshot> temp = await allItemsAsDocListWithEqualsGivenField(
        field: field, predicate: predicate, projectId: projectId);
    return temp.map((e) => this.fromJson(id: e.id, data: e.data())).toList();
  }

  ///
  /// Return a List of all [T] as [DocumentSnapshot] from a [Project] with the given [projectId] which answers the predicate of [field] == [predicate]
  /// if [projectId] si null, try to query a collection named [collectionName] from the root
  ///
  @protected
  Future<List<DocumentSnapshot>> allItemsAsDocListWithEqualsGivenField({
    @required String projectId,
    @required String field,
    @required dynamic predicate,
  }) async {
    QuerySnapshot temp = await getCollectionReference(projectId: projectId)
        .where(field, isEqualTo: predicate)
        .get();
    return temp.docs;
  }

  ///
  /// Get all [T] in collection as a [QuerySnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  @protected
  Stream<QuerySnapshot> allItemsAsQuerySnapShot({@required String projectId}) {
    CollectionReference collection =
        getCollectionReference(projectId: projectId);
    try {
      return collection.snapshots();
    } catch (error) {
      handleGeneralError(error, "'allAsQuerySnapShot' in $collectionName");
      return null;
    }
  }

  ///
  /// Get all [T] in collection as a [QuerySnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  Stream<List<T>> allItemsAsStream({@required String projectId}) {
    return allItemsAsQuerySnapShot(projectId: projectId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final temp = fromJson(id: doc.id, data: doc.data());
        return temp;
      }).toList();
    });
  }

  ///
  /// Get all [T] in collection as a [QuerySnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  Stream<List<T>> allItemsAsStreamWithArrayContainsClause(
      {@required String projectId, @required arrayField, @required value}) {
    CollectionReference collection =
        getCollectionReference(projectId: projectId);
    try {
      return collection
          .where(arrayField, arrayContains: value)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final temp = fromJson(id: doc.id, data: doc.data());
          return temp;
        }).toList();
      });
    } catch (error) {
      handleGeneralError(error,
          "'allItemsAsStreamWithArrayContainsClause' in $collectionName");
      return null;
    }
  }

  ///
  /// Get all [T] in collection as a [QuerySnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  @protected
  Stream<QuerySnapshot> allItemsAsQuerySnapShotFilteredByFields({
    @required String projectId,
    @required Map<String, dynamic> fields,
    Query collection,
  }) {
    if (collection == null) {
      collection = getCollectionReference(projectId: projectId);
    }

    fields.forEach((key, value) {
      collection = collection.where(key, isEqualTo: value);
    });
    try {
      return collection.snapshots();
    } catch (error) {
      handleGeneralError(error, "'allAsQuerySnapShot' in $collectionName");
      return null;
    }
  }

  ///
  /// Get all [T] in collection as a List of [DocumentSnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  @protected
  Future<List<DocumentSnapshot>> allItemsAsListDocsFilteredByFields({
    @required String projectId,
    @required Map<String, dynamic> fields,
    Query collection,
  }) async {
    if (collection == null) {
      collection = getCollectionReference(projectId: projectId);
    }

    fields.forEach((key, value) {
      collection = collection.where(key, isEqualTo: value);
    });
    try {
      final output = await collection.get();
      return output.docs;
    } catch (error) {
      handleGeneralError(error, "'allAsQuerySnapShot' in $collectionName");
      return null;
    }
  }

  ///
  /// Get all [T] in collection as a [QuerySnapshot]
  /// if [projectId] is null, will search for collection in root.
  /// else will search in a [Project] with the given project id
  ///
  Stream<List<T>> allItemsFilteredByFieldsAsStream({
    @required String projectId,
    @required Map<String, dynamic> fields,
  }) {
    return allItemsAsQuerySnapShotFilteredByFields(
            projectId: projectId, fields: fields)
        .map((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((e) => fromJson(id: e.id, data: e.data()))
          .toList();
    });
  }

  ///
  /// Get [CollectionReference] with [collectionName]
  /// if [projectId] is null, search that collection in root.
  /// else search in a [Project] with the given [projectId]

  @protected
  CollectionReference getCollectionReference({@required String projectId}) {
    CollectionReference collection = projectId == null
        ? FireStoreDataService().getRoot().collection(collectionName)
        : FireStoreDataService()
            .getRoot()
            .collection(Constants.PROJECTS)
            .doc(projectId)
            .collection(collectionName);
    return collection;
  }

  ///
  /// Print a log of error message [error] from function with the name of [functionName], and returns the [String] of general error
  ///
  @protected
  String handleGeneralError(dynamic error, String functionName) {
    Logger.error("error in $functionName:\n$error");
    return Constants.GENERAL_ERROR_MSG;
  }

  Stream<List<T>> allItemsAsStreamWithArrayContainsClauseAndIsEqual({
    @required String projectId,
    @required arrayField,
    @required value,
    @required Map<String, dynamic> isEqualFields,
  }) {
    try {
      CollectionReference collection =
          getCollectionReference(projectId: projectId);
      collection.where(arrayField, arrayContains: value);
      return allItemsAsQuerySnapShotFilteredByFields(
              projectId: projectId,
              fields: isEqualFields,
              collection: collection)
          .map((QuerySnapshot snapshot) {
        return snapshot.docs
            .map((e) => fromJson(id: e.id, data: e.data()))
            .toList();
      });
    } catch (error) {
      Logger.error(error.toString());
      return null;
    }
  }

  ///
  /// Get future List of [T] if the entity give [arrayField] contains the given [value]
  ///
  Future<List<T>> allItemsAsListWithArrayContainsClause(
      {@required String projectId,
      @required arrayField,
      @required value}) async {
    try {
      CollectionReference collection =
          getCollectionReference(projectId: projectId);
      collection.where(arrayField, arrayContains: value);
      final response = await collection.get();
      final output = response.docs;
      return output.map((e) => fromJson(id: e.id, data: e.data())).toList();
    } catch (error) {
      Logger.error(error.toString());
      return null;
    }
  }

  Future<List<T>> allItemsAsListWithArrayContainsClauseAndIsEqual({
    @required String projectId,
    @required arrayField,
    @required value,
    @required Map<String, dynamic> isEqualFields,
  }) async {
    try {
      CollectionReference collection =
          getCollectionReference(projectId: projectId);
      collection.where(arrayField, arrayContains: value);
      final output = await allItemsAsListDocsFilteredByFields(
          projectId: projectId, fields: isEqualFields, collection: collection);
      return output.map((e) => fromJson(id: e.id, data: e.data())).toList();
    } catch (error) {
      Logger.error(error.toString());
      return null;
    }
  }

  @override
  Future<String> deleteAllItemsForTestOnly(String projectId) async {
    if (FireStoreDataService().isTestEnv()) {
      try {
        final collection = getCollectionReference(projectId: projectId);
        final docs = await collection.get();
        getNewBatch();
        for (QueryDocumentSnapshot doc in docs.docs) {
          this.writeBatch.delete(doc.reference);
        }
        await this.writeBatch.commit();
      } catch (ignored) {}
      return "";
    } else {
      Logger.critical(
          "you cannot delete collection if you are not in test mode");
      return "ארעה שגיאה";
    }
  }
}
