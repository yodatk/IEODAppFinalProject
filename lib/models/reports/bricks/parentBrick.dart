import '../../../constants/constants.dart' as Constants;
import '../../permission.dart';
import 'BrickType.dart';
import 'templateBrick.dart';

///
/// Template Brick that can contains multiple [TemplateBricks] as children (Rows, table etc)
///
abstract class ParentBrick extends TemplateBrick {
  List<TemplateBrick> children;

  ParentBrick(
      {String attribute,
      this.children,
      BrickTypeEnum brickType,
      String decoration,
      Permission permissionCanEdit = Permission.REGULAR})
      : super(
            attribute: attribute,
            brickType: brickType,
            decoration: decoration,
            permissionCanEdit: permissionCanEdit) {
    if (this.children == null) {
      this.children = [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      Constants.TEMPLATE_BRICK_ATTR: this.attribute,
      Constants.PARENT_BRICK_CHILDREN: [
        for (TemplateBrick brick in children) brick.toMap()
      ],
    };
  }

  ParentBrick.fromJson(Map<String, dynamic> data) : super.fromMap(data) {
    this.children = data[Constants.PARENT_BRICK_CHILDREN] == null
        ? []
        : [
            for (dynamic child
                in (data[Constants.PARENT_BRICK_CHILDREN] as List<dynamic>))
              TemplateBrick.fromJson(child as Map<String, dynamic>)
          ];
  }
}
