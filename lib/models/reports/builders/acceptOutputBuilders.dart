import 'outputBuilder.dart';

///
/// part of the "BRICK WALL" pattern. to convert TemplateBrick to output files
///
abstract class AcceptOutputBuilders {
  dynamic acceptOutput(
      {Map<String, dynamic> values, OutputBuilder builder, String suffix = ""});

  String getStringValue(
      {Map<String, dynamic> values, OutputBuilder builder, String suffix = ""});
}
