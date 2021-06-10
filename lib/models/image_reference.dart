import '../constants/constants.dart' as Constants;
import 'Employee.dart';
import 'editable.dart';
import 'entity.dart';
import 'with_image.dart';

class ImageReference extends Entity implements Editable, WithImage {
  String name;

  String fullPath;
  String imageUrl;
  DateTime timeModified;
  EmployeeForDocs lastEditor;

  ImageReference({
    String id = "",
    this.name = "",
    this.fullPath = "",
    this.imageUrl,
    this.timeModified,
    this.lastEditor,
  }) : super(
            id: id, timeCreated: DateTime.now(), timeModified: DateTime.now()) {
    if (this.timeModified == null) {
      this.timeModified = DateTime.now();
    }
  }

  String getUrl() => this.imageUrl;

  String getId() => this.id;

  String getPath() => this.fullPath;

  @override
  bool isWithImage() =>
      this.imageUrl != null &&
      this.imageUrl.isNotEmpty &&
      this.fullPath != null &&
      this.fullPath.isNotEmpty;

  @override
  String toString() {
    return this.name;
  }

  ImageReference.copy(ImageReference other) : super.copy(other) {
    this.name = other.name;
    this.fullPath = other.fullPath;
    this.imageUrl = other.imageUrl;
    this.lastEditor = other.lastEditor.clone();
    this.timeModified = other.timeModified;
  }

  ImageReference.fromJson(String id, Map<String, dynamic> data)
      : super.fromJson(id: id, data: data) {
    this.name = data[Constants.IMAGE_REF_NAME] as String ?? "";
    this.fullPath =
        data[Constants.IMAGE_REF_FULL_PATH] as String ?? ""; // <String>[];
    this.imageUrl = data[Constants.IMAGE_REF_REFERENCE] as String ?? null;
    this.lastEditor = data[Constants.IMAGE_REF_EDITOR] == null
        ? null
        : EmployeeForDocs.fromJson(
            data[Constants.IMAGE_REF_EDITOR] as Map<String, dynamic>);
    this.timeModified = data[Constants.IMAGE_REF_LAST_MODIFIED] == null
        ? DateTime.now().toLocal()
        : DateTime.parse(data[Constants.IMAGE_REF_LAST_MODIFIED] as String)
            .toLocal();
  }

  Map<String, dynamic> toJson() {
    return {...toMap(), ...super.toJson()};
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.IMAGE_REF_NAME: this.name,
      Constants.IMAGE_REF_FULL_PATH: this.fullPath,
      Constants.IMAGE_REF_LAST_MODIFIED: this.timeModified.toIso8601String(),
      Constants.IMAGE_REF_EDITOR: this.lastEditor != null
          ? this.lastEditor.toJson()
          : Map<String, dynamic>(),
      Constants.IMAGE_REF_REFERENCE: this.imageUrl,
    };
  }

  ImageReference clone() {
    return ImageReference.copy(this);
  }

  @override
  bool isNew() {
    return this.imageUrl == null || this.imageUrl == '';
  }

  @override
  void setLastEditor(EmployeeForDocs newEmployee) {
    this.lastEditor = newEmployee;
  }

  @override
  void updateLastModified() {
    this.timeModified = DateTime.now();
  }

  @override
  int get hashCode => this.imageUrl.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is ImageReference) {
      return this.name == other.name &&
          this.imageUrl == other.imageUrl &&
          this.lastEditor == other.lastEditor &&
          this.timeModified == other.timeModified &&
          this.fullPath == other.fullPath;
    } else {
      return false;
    }
  }

  @override
  bool validateMustFields() {
    return this.name != null &&
        this.imageUrl != null &&
        this.fullPath != null &&
        this.lastEditor != null;
  }
}
