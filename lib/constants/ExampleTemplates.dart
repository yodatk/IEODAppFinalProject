library templates;

import '../models/reports/bricks/FunctionDropDownBrick.dart';
import '../models/reports/bricks/EmptyBrick.dart';
import '../models/reports/bricks/templateBrick.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../constants/constants.dart' as Constants;
import '../models/reports/bricks/ChoiceChipBrick.dart';
import '../models/reports/bricks/DateTimeBrick.dart';
import '../models/reports/bricks/DropDownBrick.dart';
import '../models/reports/bricks/PageBrick.dart';
import '../models/reports/bricks/ReadOnlyTextBrick.dart';
import '../models/reports/bricks/RowBrick.dart';
import '../models/reports/bricks/TableBrick.dart';
import '../models/reports/bricks/TextBrick.dart';
import '../models/reports/bricks/TitleBrick.dart';
import '../models/reports/templates/FunctionResolver.dart';
import '../models/reports/templates/Template.dart';

Map<TemplateTypeEnum, Template Function()> templateToFunctionMap = {
  TemplateTypeEnum.Mechanical: buildMechTemplate, // deprecated
  TemplateTypeEnum.QualityControlForMechanical: buildQualControl,
  TemplateTypeEnum.DeepTarget: buildDeepTargets,
  TemplateTypeEnum.QualityControlForManual: buildManualQualControl,
  TemplateTypeEnum.BunkersClearance: buildBunkersClearance,
  TemplateTypeEnum.GeneralMechanical: buildGeneralMechTemplate,
  TemplateTypeEnum.DailyClearance: buildDailyClearance,
  TemplateTypeEnum.EmergencyPracticeDocumentation:
      buildEmergencyPracticeDocumentation,
};

List<Map<String, dynamic>> getTemplateJsons() {
  var vals = (templateToFunctionMap.values
      .map((template) => template().toJson())
      .toList() as List<Map<String, dynamic>>);
  return vals;
}

/// <<DEPRECATED>>
/// Mechanical Template -> build on the template that can be found here:
/// <<DEPRECATED>>
Template buildMechTemplate() {
  return Template(
    templateType: TemplateTypeEnum.Mechanical,
    name: describeEnum(TemplateTypeEnum.Mechanical), //"Mechanical Report",
    templateBricks: <TemplateBrick>[
      TitleBrick(attribute: "דו״ח מכאני", text: 'דו"ח מכאני'),
      EmptyBrick(),
      RowBrick(attribute: "date+plot", children: <TemplateBrick>[
        DateTimeBrick(
          attribute: "תאריך הדו״ח",
          // maxDateTime: DateTime.now(),
          minDateTime: null,
          input: InputType.date,
          isRequired: false,
        ),
        ReadOnlyTextBrick(
            attribute: Constants.PLOT_ID,
            decoration: "שם חלקה",
            maxLen: 30,
            singleEntityEnum: SingleResolvedEntityEnum.PLOT,
            fieldName: Constants.PLOT_NAME,
            text: ""),
        // TextBrick(attribute: "מספר חלקה / תת חלקה", maxLen: 5, isRequired: true),
      ]),
      TextBrick(attribute: "כלים", isRequired: false),
      TextBrick(attribute: "משימות", isRequired: false),
      TitleBrick(text: "הפסקות", titleSize: TitleSizeEnum.HEADLINE_4),
      TableBrick(
          attribute: "הפסקות",
          rowCount: 5,
          showColumnNames: false,
          children: <TemplateBrick>[
            DateTimeBrick(
                attribute: "שעת הפסקה",
                decoration: "שעת הפסקה",
                // maxDateTime: DateTime.now(),
                input: InputType.time,
                width: 10),
            DateTimeBrick(
                attribute: "המשך",
                decoration: "המשך",
                // maxDateTime: DateTime.now(),
                input: InputType.time,
                width: 5),
            TextBrick(
              attribute: "סיבה",
              decoration: "סיבה",
              lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
            ),
            TextBrick(
              attribute: "הערות",
              decoration: "הערות",
              lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
            ),
          ]),
      EmptyBrick(),
      DateTimeBrick(
        attribute: "שעת סיום העבודה",
        maxDateTime: null,
        minDateTime: null,
        input: InputType.time,
        isRequired: false,
      ),
      EmptyBrick(),
      TextBrick(attribute: "תקלות"),
      EmptyBrick(),
      TextBrick(attribute: "ממצאים"),
      EmptyBrick(),
      TextBrick(
        attribute: "הערות",
        decoration:
            "הערות (יש להתייחס לתכנון מול ביצוע היומי ולאירועים משמעותיים)",
      ),
      EmptyBrick(),
      RowBrick(attribute: "ראש צוות מכאני", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "ראש צוות מכאני",
            decoration: "ראש צוות מכאני",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת ראש צוות מכאני",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      RowBrick(attribute: "מנהל אתר", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל אתר",
            decoration: "מנהל אתר",
            listEntityEnum: ResolvedEntityListEnum.ADMINS,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת מנהל אתר",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
    ],
  );
}

Template buildQualControl() {
  return Template(
    templateType: TemplateTypeEnum.QualityControlForMechanical,
    name: describeEnum(TemplateTypeEnum
        .QualityControlForMechanical), //"Quality Control for Mechanical",
    templateBricks: <TemplateBrick>[
      TitleBrick(text: "בקרת איכות"),
      EmptyBrick(),
      ReadOnlyTextBrick(
          attribute: Constants.PLOT_ID,
          decoration: "שם חלקה",
          maxLen: 30,
          singleEntityEnum: SingleResolvedEntityEnum.PLOT,
          fieldName: Constants.PLOT_NAME,
          text: ""),
      RowBrick(
        attribute: "date+plot",
        //maybe attribute not good
        children: <TemplateBrick>[
          DateTimeBrick(
            attribute: "תאריך הדו״ח",
            //maxDateTime: DateTime.now(),
            minDateTime: null,
            input: InputType.date,
            isRequired: false,
          ),
          DateTimeBrick(
            attribute: "שעת בקרה",
            maxDateTime: null,
            minDateTime: null,
            input: InputType.time,
            isRequired: false,
          ),
        ],
      ),
      TextBrick(
        attribute: "פעולות",
        decoration: "פעולות",
        isRequired: false,
      ),
      TextBrick(
        attribute: "שם המפעיל",
        lines: null,
        maxLen: 30,
        decoration: "שם המפעיל",
        isRequired: false,
      ),
      TitleBrick(text: "פעולות", titleSize: TitleSizeEnum.HEADLINE_4),
      TableBrick(
        attribute: "פעולות",
        rowCount: 6,
        showColumnNames: false,
        children: <TemplateBrick>[
          TextBrick(
            attribute: "סוג אמצעי",
            lines: null,
            decoration: "סוג אמצעי",
            lineLimit: 15,
          ),
          TextBrick(
            attribute: "עומק",
            lines: null,
            decoration: "עומק",
            maxLen: 10,
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          TextBrick(
            attribute: "רוחב",
            lines: null,
            decoration: "רוחב",
            maxLen: 10,
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          TextBrick(
            attribute: "פריסה",
            decoration: "פריסה",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          TextBrick(
            attribute: "ממצאים",
            decoration: "ממצאים",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          TextBrick(
            attribute: "הערות",
            decoration: "הערות",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
        ],
      ),
      EmptyBrick(),
      ChoiceChipBrick(
          attribute: "תוצאות הבקרה",
          isRequired: false,
          choices: ["תקין", "לא תקין"]),
      TextBrick(
        attribute: "פירוט ממצאים/תקלות שאותרו",
        decoration: "ממצאים/תקלות",
      ),
      EmptyBrick(),
      RowBrick(attribute: "ראש צוות", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "ראש צוות",
            decoration: "ראש צוות",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת ראש צוות",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      EmptyBrick(),
      RowBrick(attribute: "מנהל קבוצה", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל קבוצה",
            decoration: "מנהל קבוצה",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת מנהל קבוצה",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      EmptyBrick(),
      RowBrick(attribute: "מנהל אתר", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל אתר",
            decoration: "מנהל אתר",
            listEntityEnum: ResolvedEntityListEnum.ADMINS,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת מנהל אתר",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
    ],
  );
}

///
/// Manual Quality Control Template -> build on the template that can be found here:
///
Template buildManualQualControl() {
  return Template(
    templateType: TemplateTypeEnum.QualityControlForManual,
    name: describeEnum(TemplateTypeEnum
        .QualityControlForManual), //"Quality Control for Manual",
    templateBricks: <TemplateBrick>[
      TitleBrick(text: "בקרת איכות לעבודות פינוי ידני"),
      EmptyBrick(),
      RowBrick(attribute: "date+plot", children: <TemplateBrick>[
        ReadOnlyTextBrick(
            attribute: Constants.PLOT_ID,
            decoration: "שם חלקה",
            maxLen: 30,
            text: "",
            fieldName: Constants.PLOT_NAME,
            singleEntityEnum: SingleResolvedEntityEnum.PLOT),
        DateTimeBrick(
          attribute: "תאריך",
          minDateTime: null,
          input: InputType.date,
          isRequired: false,
        ),
      ]),
      TextBrick(
        attribute: "פעולות",
        decoration: "פעולות",
        isRequired: false,
      ),
      EmptyBrick(),
      TableBrick(
        attribute: "פעולות",
        rowCount: 6,
        showColumnNames: false,
        children: <TemplateBrick>[
          TextBrick(
            attribute: "תת חלקה",
            lines: null,
            decoration: "תת חלקה",
            lineLimit: 15,
          ),
          TextBrick(
            attribute: "מס' סטריפ",
            lines: null,
            decoration: "מס' סטריפ",
            lineLimit: 15,
          ),
          TextBrick(
            attribute: "אמצעי בקרה",
            decoration: "אמצעי בקרה",
            lineLimit: 15,
          ),
          TextBrick(
            attribute: "מבצע הבקרה",
            lines: null,
            decoration: "מבצע הבקרה",
            lineLimit: 15,
          ),
          TextBrick(
            attribute: "ממצאים",
            decoration: "ממצאים",
            lineLimit: 15,
          ),
          TextBrick(
            attribute: "הערות",
            decoration: "הערות",
            lineLimit: 15,
          ),
        ],
      ),
      EmptyBrick(),
      ChoiceChipBrick(
          attribute: "תוצאות הבקרה",
          isRequired: false,
          choices: ["תקין", "לא תקין"]),
      TextBrick(
        attribute: "פירוט ממצאים/הערות",
        decoration: "ממצאים/הערות",
      ),
      EmptyBrick(),
      RowBrick(
        attribute: "ראש צוות",
        children: <TemplateBrick>[
          FunctionDropDownBrick(
              attribute: "ראש צוות",
              decoration: "ראש צוות",
              listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
              fieldName: Constants.EMPLOYEE_NAME),
          TextBrick(
            attribute: "חתימת ראש צוות",
            decoration: "חתימה",
            maxLen: 20,
            isRequired: false,
          ),
        ],
      ),
      EmptyBrick(),
      RowBrick(
        attribute: "מנהל אתר",
        children: <TemplateBrick>[
          FunctionDropDownBrick(
              attribute: "מנהל אתר",
              decoration: "מנהל אתר",
              listEntityEnum: ResolvedEntityListEnum.ADMINS,
              fieldName: Constants.EMPLOYEE_NAME),
          TextBrick(
            attribute: "חתימת מנהל אתר",
            decoration: "חתימה",
            maxLen: 20,
            isRequired: false,
          ),
        ],
      ),
    ],
  );
}

///
/// Bunkers Clearance Template -> build on the template that can be found here:
///
Template buildBunkersClearance() {
  return Template(
    templateType: TemplateTypeEnum.BunkersClearance,
    name: describeEnum(TemplateTypeEnum.BunkersClearance),
    templateBricks: <TemplateBrick>[
      TitleBrick(text: "זיכוי בונקרים"),
      EmptyBrick(),
      ReadOnlyTextBrick(
          attribute: Constants.PLOT_ID,
          decoration: "שם חלקה",
          maxLen: 30,
          text: "",
          fieldName: Constants.PLOT_NAME,
          singleEntityEnum: SingleResolvedEntityEnum.PLOT),
      EmptyBrick(),
      TableBrick(
        attribute: "בונקרים",
        rowCount: 10,
        showColumnNames: false,
        children: <TemplateBrick>[
          TextBrick(
            attribute: "צוות ידני",
            decoration: "צוות ידני",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          DateTimeBrick(
            attribute: "תאריך",
            minDateTime: null,
            input: InputType.date,
            isRequired: false,
          ),
          TextBrick(
            attribute: "צוות מכאני",
            decoration: "צוות מכאני",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          DateTimeBrick(
            attribute: "תאריך מכאני",
            minDateTime: null,
            input: InputType.date,
            isRequired: false,
            decoration: "תאריך",
          ),
          TextBrick(
            attribute: "ממצאים/הערות",
            decoration: "ממצאים/הערות",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
        ],
      ),
      EmptyBrick(),
      RowBrick(attribute: "מנהל קבוצה", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל קבוצה",
            decoration: "מנהל קבוצה",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        DateTimeBrick(
          attribute: "תאריך מנהל קבוצה",
          minDateTime: null,
          input: InputType.date,
          isRequired: false,
          decoration: "תאריך",
        ),
        TextBrick(
          attribute: "חתימת מנהל קבוצה",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      EmptyBrick(),
      RowBrick(attribute: "מנהל אתר", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל אתר",
            decoration: "מנהל אתר",
            listEntityEnum: ResolvedEntityListEnum.ADMINS,
            fieldName: Constants.EMPLOYEE_NAME),
        DateTimeBrick(
          attribute: "תאריך מנהל אתר",
          minDateTime: null,
          input: InputType.date,
          isRequired: false,
          decoration: "תאריך",
        ),
        TextBrick(
          attribute: "חתימת מנהל אתר",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
    ],
  );
}

///
/// Deep Targets Template -> build on the template that can be found here:
///
Template buildDeepTargets() {
  return Template(
    templateType: TemplateTypeEnum.DeepTarget,
    name: describeEnum(TemplateTypeEnum.DeepTarget), //"Deep Target",
    templateBricks: <TemplateBrick>[
      TitleBrick(
        attribute: "דו״ח זיכוי מטרות עומק / פיזור",
        text: "דו״ח זיכוי מטרות עומק / פיזור",
      ),
      EmptyBrick(height: 30.0),
      TitleBrick(
        attribute: "טבלת מטרות שאותרו בעבודת ידנית ולא זוכו",
        text: "טבלת מטרות שאותרו בעבודת ידנית ולא זוכו",
        titleSize: TitleSizeEnum.HEADLINE_4,
      ),
      EmptyBrick(),
      RowBrick(attribute: "date+plot", children: <TemplateBrick>[
        DateTimeBrick(
            attribute: "תאריך הדו״ח",
            // maxDateTime: DateTime.now(),
            minDateTime: null,
            input: InputType.date,
            isRequired: false),
        ReadOnlyTextBrick(
            attribute: Constants.PLOT_ID,
            decoration: "שם חלקה",
            maxLen: 30,
            fieldName: Constants.PLOT_NAME,
            singleEntityEnum: SingleResolvedEntityEnum.PLOT,
            text: ""),
        // TextBrick(attribute: "מספר חלקה / תת חלקה", maxLen: 5, isRequired: true),
      ]),
      EmptyBrick(),
      TableBrick(
        attribute: "זיהויים",
        rowCount: 5,
        showColumnNames: false,
        children: <TemplateBrick>[
          TextBrick(
            attribute: "תת חלקה",
            lines: null,
            decoration: "תת חלקה",
            lineLimit: 20,
          ),
          TextBrick(
            attribute: "מס׳ סטריפ",
            lines: null,
            decoration: "מס׳ סטריפ",
            lineLimit: 20,
          ),
          DropDownBrick(
            attribute: 'סוג מטרה',
            decoration: 'סוג מטרה',
            choices: ["עומק", "פיזור", "החרגה מכנית"],
            isRequired: false,
          ),
          TextBrick(
            attribute: "הערות",
            decoration: "הערות",
            lineLimit: 20,
          ),
        ],
      ),
      EmptyBrick(),
      RowBrick(attribute: "ראש צוות ידני", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "ראש צוות ידני",
            decoration: "ראש צוות ידני",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת ראש צוות ידני",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      EmptyBrick(),
      RowBrick(attribute: "אישור מנהל קבוצה", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל קבוצה",
            decoration: "מנהל קבוצה",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת מנהל קבוצה",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      PageBrick(),
      TitleBrick(
        attribute: "דוח זיכוי מטרות עומק / פיזור",
        text: "דוח זיכוי מטרות עומק / פיזור",
        titleSize: TitleSizeEnum.HEADLINE_4,
      ),
      EmptyBrick(),
      RowBrick(attribute: "date+plot", children: <TemplateBrick>[
        DateTimeBrick(
          attribute: 'תאריך הדו"ח מכאני',
          // maxDateTime: DateTime.now(),
          minDateTime: null,
          input: InputType.date,
          isRequired: false,
          decoration: 'תאריך הדו"ח',
        ),
        ReadOnlyTextBrick(
            attribute: "חלקה מכאני",
            decoration: "שם חלקה",
            maxLen: 30,
            fieldName: Constants.PLOT_NAME,
            singleEntityEnum: SingleResolvedEntityEnum.PLOT,
            text: ""),
        // TextBrick(attribute: "מספר חלקה / תת חלקה", maxLen: 5, isRequired: true),
      ]),
      EmptyBrick(),
      TableBrick(
        attribute: "זיהויים מכאניים",
        rowCount: 5,
        showColumnNames: false,
        children: <TemplateBrick>[
          TextBrick(
            attribute: "תת חלקה מכאני",
            lines: null,
            decoration: "תת חלקה",
            lineLimit: 20,
          ),
          TextBrick(
            attribute: "מספר סטריפ מכאני",
            lines: null,
            decoration: "מס׳ סטריפ",
            lineLimit: 20,
          ),
          DropDownBrick(
            attribute: "סוג מטרה מכאני",
            decoration: 'סוג מטרה',
            choices: ["עומק", "פיזור", "החרגה מכנית"],
            isRequired: false,
          ),
          TextBrick(
            attribute: "אמצעי מכאני",
            decoration: "פונה באמצעות",
            lineLimit: 20,
          ),
          TextBrick(
            attribute: "הערות מכאני",
            decoration: "הערות",
            lineLimit: 20,
          ),
        ],
      ),
      EmptyBrick(),
      RowBrick(attribute: "ראש צוות מכני", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "ראש צוות מכני",
            decoration: "ראש צוות מכני",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת ראש צוות מכני",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
      EmptyBrick(),
      RowBrick(attribute: "אישור מנהל קבוצה", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "מנהל קבוצה מכאני",
            decoration: "מנהל קבוצה",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
          attribute: "חתימת מנהל קבוצה מכאני",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ])
    ],
  );
}

///
/// General Mechanical Template -> build on the template that can be found here:
///
Template buildGeneralMechTemplate() {
  return Template(
    templateType: TemplateTypeEnum.GeneralMechanical,
    name: describeEnum(
        TemplateTypeEnum.GeneralMechanical), //"General Mechanical Report",
    templateBricks: <TemplateBrick>[
      TitleBrick(attribute: "דו״ח מכאני", text: 'דו"ח מכאני'),
      EmptyBrick(),
      DateTimeBrick(
          attribute: "תאריך הדו״ח",
          // maxDateTime: DateTime.now(),
          minDateTime: null,
          input: InputType.date,
          isRequired: false),
      RowBrick(attribute: "manager_name+subject", children: <TemplateBrick>[
        TextBrick(
          attribute: "שם מנהל",
          maxLen: 30,
          isRequired: false,
          lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
        ),
        TextBrick(
          attribute: "תפקיד",
          maxLen: 30,
          isRequired: false,
          lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
        ),
      ]),
      RowBrick(attribute: "sub_plot+plot", children: <TemplateBrick>[
        ReadOnlyTextBrick(
            attribute: Constants.PLOT_ID,
            decoration: "שם חלקה",
            maxLen: 30,
            fieldName: Constants.PLOT_NAME,
            singleEntityEnum: SingleResolvedEntityEnum.PLOT,
            text: ""),
        TextBrick(
            attribute: "תת חלקה",
            maxLen: 30,
            isRequired: false,
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT),
      ]),
      EmptyBrick(),
      DropDownBrick(
          attribute: 'סוג טופס',
          decoration: 'סוג טופס',
          choices: [
            "דוח סקר",
            "דוח בקרת איכות",
            "דוח גריסה",
            "דוח תרגול צוות חירום",
            "דוח הכנת קרקע",
            "דוח פינוי",
            "דוח פעולה מסיימת"
          ],
          isRequired: false),
      TextBrick(attribute: "שם מפעיל", maxLen: 30, isRequired: false),
      TextBrick(attribute: "אנשי צוות", isRequired: false),
      TextBrick(
          attribute: "מס' פיצוצים יומי",
          maxLen: 20,
          isNumber: true,
          isRequired: false),
      EmptyBrick(),
      TextBrick(attribute: "תיאור הפעולות", isRequired: false),
      EmptyBrick(),
      TextBrick(attribute: "אירועים חריגים", isRequired: false),
      EmptyBrick(),
      TextBrick(attribute: "תקלות מכאניות", isRequired: false),
      EmptyBrick(),
      TextBrick(attribute: "לקחים", isRequired: false),
      EmptyBrick(),
      TextBrick(attribute: "הערות", isRequired: false),
    ],
  );
}

///
/// Daily Clearance Template -> build on the template that can be found here:
///
Template buildDailyClearance() {
  return Template(
    templateType: TemplateTypeEnum.DailyClearance,
    name: describeEnum(TemplateTypeEnum.DailyClearance),
    templateBricks: <TemplateBrick>[
      TitleBrick(text: "דוח פינוי יומי"),
      EmptyBrick(),
      DateTimeBrick(
          attribute: "תאריך עדכון",
          minDateTime: null,
          input: InputType.date,
          isRequired: false),
      RowBrick(attribute: "שעות", children: [
        DateTimeBrick(
            attribute: "שעת תחילת העבודה",
            minDateTime: null,
            input: InputType.time,
            isRequired: false),
        DateTimeBrick(
            attribute: "שעת סיום העבודה",
            minDateTime: null,
            input: InputType.time,
            isRequired: false),
      ]),
      EmptyBrick(),
      RowBrick(attribute: 'פרטי שטח', children: [
        TextBrick(
            attribute: "מס' חלקות שהיו בעבודה",
            decoration: "מס' חלקות שהיו בעבודה",
            isRequired: false,
            isNumber: true,
            maxLen: 20),
        TextBrick(
            attribute: "מס' שד'מים שהיו בעבודה",
            decoration: "מס' שד'מים שהיו בעבודה",
            isRequired: false,
            isNumber: true,
            maxLen: 20),
      ]),
      EmptyBrick(),
      TextBrick(
        attribute: "כלים באתר",
        decoration: "כלים באתר",
      ),
      EmptyBrick(),
      RowBrick(attribute: "מנהלים 1", children: [
        FunctionDropDownBrick(
            attribute: "מנהל אתר",
            decoration: "מנהל אתר",
            listEntityEnum: ResolvedEntityListEnum.ADMINS,
            fieldName: Constants.EMPLOYEE_NAME),
        TextBrick(
            attribute: "מנהל איכות ובטיחות",
            decoration: "מנהל איכות ובטיחות",
            maxLen: 30,
            isRequired: false),
      ]),
      EmptyBrick(),
      RowBrick(attribute: "מנהלים 2", children: [
        FunctionDropDownBrick(
            attribute: "מנהל קבוצה ידנית",
            decoration: "מנהל קבוצה ידנית",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        FunctionDropDownBrick(
            attribute: "מנהל קבוצה מכנית",
            decoration: "מנהל קבוצה מכנית",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
      ]),
      EmptyBrick(),
      TextBrick(
          attribute: 'סה"כ עובדים ביום זה',
          decoration: 'סה"כ עובדים ביום זה',
          isNumber: true,
          maxLen: 20,
          isRequired: false),
      EmptyBrick(),
      TitleBrick(
          text: "גידור לפני ת. עבודה", titleSize: TitleSizeEnum.HEADLINE_6),
      RowBrick(attribute: "גידור לפני ת. עבודה", children: <TemplateBrick>[
        DateTimeBrick(
          decoration: "שעה",
          attribute: "שעה",
          minDateTime: null,
          input: InputType.time,
          isRequired: false,
        ),
        FunctionDropDownBrick(
            attribute: "שם הבודק",
            decoration: "שם הבודק",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        ChoiceChipBrick(
            attribute: "מצב תקינות",
            isRequired: false,
            choices: ["תקין", "לא תקין"]),
      ]),
      EmptyBrick(),
      TitleBrick(
          text: "בדיקת אמבולנס וצ. חילוץ", titleSize: TitleSizeEnum.HEADLINE_6),
      RowBrick(attribute: "בדיקת אמבולנס וצ. חילוץ", children: <TemplateBrick>[
        DateTimeBrick(
          attribute: "שעה1",
          decoration: "שעה",
          minDateTime: null,
          input: InputType.time,
          isRequired: false,
        ),
        FunctionDropDownBrick(
            attribute: "שם הבודק1",
            decoration: "שם הבודק",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        ChoiceChipBrick(
            attribute: "1מצב תקינות",
            decoration: "מצב תקינות",
            isRequired: false,
            choices: ["תקין", "לא תקין"]),
      ]),
      EmptyBrick(),
      PageBrick(),
      TitleBrick(
          text: "תיאור הפעילות וההספק היומי באתר פינוי",
          titleSize: TitleSizeEnum.HEADLINE_5),
      EmptyBrick(),
      TableBrick(
        attribute: "תיאור הפעילות וההספק היומי באתר פינוי",
        rowCount: 10,
        showColumnNames: false,
        children: <TemplateBrick>[
          TextBrick(
            attribute: "בעל תפקיד",
            lines: null,
            decoration: "בעל תפקיד",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          TextBrick(
            attribute: "שם",
            lines: null,
            decoration: "שם",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
          TextBrick(
            attribute: "אחריות, ביצוע והספק במהלך היום",
            decoration: "אחריות, ביצוע והספק במהלך היום",
            lineLimit: 2 * Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
          ),
        ],
      ),
      EmptyBrick(),
      TextBrick(
        attribute: "אירועים חריגים",
        decoration: "אירועים חריגים",
      ),
      EmptyBrick(),
      TextBrick(
        attribute: "הערות כלליות",
        decoration: "הערות כלליות",
      ),
      EmptyBrick(),
      TitleBrick(
          text: "בדיקת גידור בסיום העבודה",
          titleSize: TitleSizeEnum.HEADLINE_6),
      RowBrick(attribute: "בדיקת גידור בסיום העבודה", children: <TemplateBrick>[
        FunctionDropDownBrick(
            attribute: "2שם הבודק",
            decoration: "שם הבודק",
            listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
            fieldName: Constants.EMPLOYEE_NAME),
        ChoiceChipBrick(
            attribute: "מצב תקינות2",
            decoration: "מצב תקינות",
            isRequired: false,
            choices: ["תקין", "לא תקין"]),
      ]),
      EmptyBrick(),
      TitleBrick(
          text: "הגורם המאשר את הדוח", titleSize: TitleSizeEnum.HEADLINE_6),
      RowBrick(attribute: "הגורם המאשר את הדוח", children: <TemplateBrick>[
        TextBrick(
            attribute: "שם",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
            isRequired: false),
        TextBrick(
            attribute: "תפקיד",
            lineLimit: Constants.SHORT_TEXT_DEFAULT_ROW_LIMIT,
            isRequired: false),
        TextBrick(
          attribute: "חתימה",
          decoration: "חתימה",
          maxLen: 20,
          isRequired: false,
        ),
      ]),
    ],
  );
}

Template buildEmergencyPracticeDocumentation() {
  return Template(
    templateType: TemplateTypeEnum.EmergencyPracticeDocumentation,
    name: describeEnum(TemplateTypeEnum.EmergencyPracticeDocumentation),
    templateBricks: <TemplateBrick>[
      TitleBrick(text: "תיעוד תרגול חירום"),
      EmptyBrick(),
      DateTimeBrick(
          attribute: "תאריך",
          decoration: "תאריך",
          minDateTime: null,
          input: InputType.date,
          isRequired: false),
      ReadOnlyTextBrick(
          attribute: Constants.PROJECT_NAME,
          decoration: "שם הפרויקט",
          maxLen: 30,
          text: "",
          fieldName: Constants.PROJECT_NAME,
          singleEntityEnum: SingleResolvedEntityEnum.PROJECT),
      FunctionDropDownBrick(
          attribute: "מנהל עבודה",
          decoration: "מנהל עבודה",
          listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
          fieldName: Constants.EMPLOYEE_NAME),
      EmptyBrick(),
      TextBrick(
          attribute: "תיאור פעילות באתר",
          decoration: "תיאור פעילות באתר",
          isRequired: false),
      EmptyBrick(),
      TextBrick(
          attribute: "תיאור התרגול",
          decoration: "תיאור התירגול",
          isRequired: false),
      EmptyBrick(),
      TableBrick(
          attribute: "משתתפים בתרגול",
          rowCount: 5,
          showColumnNames: false,
          children: <TemplateBrick>[
            FunctionDropDownBrick(
                attribute: "שם ושם משפחה",
                decoration: "שם ושם משפחה",
                listEntityEnum: ResolvedEntityListEnum.EMPLOYEES,
                fieldName: Constants.EMPLOYEE_NAME),
            TextBrick(
              attribute: "תפקיד בצוות",
              decoration: "תפקיד בצוות",
              lineLimit: 20,
            ),
          ]),
      EmptyBrick(),
      TextBrick(
        attribute: "לקחים עיקריים: תיאור תמציתי של לקחים להמשך מהתרגול",
        decoration: "לקחים עיקריים",
      ),
      EmptyBrick(),
      RowBrick(attribute: "manager+date+sign", children: <TemplateBrick>[
        TextBrick(attribute: "מנהל העבודה", maxLen: 20, isRequired: false),
        DateTimeBrick(
            decoration: "תאריך",
            attribute: "תאריך2",
            minDateTime: null,
            input: InputType.date,
            isRequired: false),
        TextBrick(
            attribute: "חתימת מנהל העבודה",
            decoration: "חתימה",
            maxLen: 20,
            isRequired: false),
      ]),
    ],
  );
}
