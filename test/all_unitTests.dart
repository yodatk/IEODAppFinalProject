import 'models/Employee_test.dart';
import 'models/ImageFolder_test.dart';
import 'models/driveArrangement_test.dart';
import 'models/plot_test.dart';
import 'models/project_test.dart';
import 'models/report_test.dart';
import 'models/site_test.dart';
import 'models/strip_test.dart';
import 'models/template_test.dart';
import 'models/workArrangement_test.dart';

void main() {
  runEmployeeTests();
  runProjectTests();
  runDriveArrangementTests();
  runWorkArrangementTests();
  runImageFolderTests();
  runSiteTests();
  runPlotTests();
  runStripTests();
  runReportTests();
  runTemplateTests();
}
