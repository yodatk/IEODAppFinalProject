library constants;

import 'package:flutter/material.dart';

/// General Config

const NOT_IN_ENV_ERROR = "NOT IN ENV";
const String APP_NAME = "IEOD App";

const String GENERAL_ERROR_MSG = "אראה שגיאה. נסה שוב מאוחד יותר";

/// General Config

const String MAIN_TOOLTIP_BUTTON = 'דרורררר תחץ על הכפתור!';
const String MAIN_TEXT_BODY = 'כמות הפעמים שלחצת על הכפתור:';

// Collector Constants

const String COLLECTOR_ANDROID_APP_URL = "arcgis-collector://";
const String COLLECTOR_PLAYSTORE_URL =
    "https://play.google.com/store/apps/details?id=com.esri.arcgis.collector";

// Model Constants
const String ENTITY_ID = "ID";
const String ENTITY_CREATED = "TimeCreated";
const String ENTITY_MODIFIED = "TimeModified";

// Employee Constants
const String EMPLOYEE_COLLECTION_NAME = "Employees";
const String EMPLOYEE_NAME = "שם";
const String EMPLOYEE_EMAIL = "אימייל";
const String EMPLOYEE_PHONE_NUMBER = "מס׳ טלפון";
const String EMPLOYEE_PERMISSION = 'הרשאה';
const String EMPLOYEE_IS_HAND_WORKER = "עובד ידני";
const String EMPLOYEE_PROJECTS = "פרויקטים";
const String EMPLOYEE_IMAGE_URL = "קישור תמונה";
const String EMPLOYEE_IMAGE_PATH = "קישור לקובץ";

// Employee Functions Constants
const String WEAK_PASSWORD_MSG = 'הסיסמא חלשה מדיי. נסה סיסמא אחרת';
const String EMPLOYEE_EXISTS_MSG = 'קיים עובד עם מייל זה';
const String LOGIN_FAILED_MSG = 'שגיאת התחברות. בדקו שהפרטים שהזנתם נכונים';

// Vehicle Constants
const String VEHICLE_MODEL = "רכב";
const String VEHICLE_DRIVER = "נהג";
const String VEHICLE_PASSENGERS = "נוסעים";
const String VEHICLE_DESTINATION = "יעד";

// Drive Arrangement Constants
const String DA_DATE = "תאריך";
const String DA_DEST = "מיקום";
const String DA_VEHICLES = "רכבים";
const String DA_LAST_EDITOR = "עורך אחרון";
const String DA_ARRANGEMENT = "סידור נסיעה";

// Work Arrangement Constants
const String WA_DATE = "תאריך";
const String WA_ARRANGEMENT = "סידור עבודה";
const String WA_FREE_TEXT_INFO = "פירוט";
const String WA_LAST_EDITOR = "עורך אחרון";

// MapFolder Constants
const String MAP_FOLDER_REFERENCES = "מיקום תמונות";
const String MAP_FOLDER_IMAGES = "Images";
const String MAP_FOLDER_DATE = "תאריך";
const String MAP_FOLDER_NUM_OF_IMAGES = "מספר תמונות";
const String MAP_FOLDER_COLLECTION_NAME = "MapFolders";

// ImageReference Constants
const String IMAGE_REF_NAME = "שם";
const String IMAGE_REF_FULL_PATH = "שם קובץ";
const String IMAGE_REF_REFERENCE = "תמונה";
const String IMAGE_REF_EDITOR = "עורך אחרון";
const String IMAGE_REF_LAST_MODIFIED = "זמן עריכה אחרון";

// Site Constants
const String SITE_COLLECTION_NAME = "Sites";
const String SITE_NAME = "שם";
const String SITE_PLOTS = "חלקות";

// Template Constants
const String TEMPLATE_COLLECTION_NAME = "Templates";
const String TEMPLATE_MECHANICAL_NAME = "Mechanical";
const String TEMPLATE_MECHANICAL_COLLECTION_NAME = "All Mechanical";
const String TEMPLATE_MANUAL_NAME = "Manual";
const String TEMPLATE_MANUAL_COLLECTION_NAME = "All Manual";
const String TEMPLATE_LATEST_NAME = "Latest";
const String TEMPLATE_NAME = "name";
const String TEMPLATE_TYPE = "type";
const String TEMPLATE_BRICKS = "bricks";

// TemplateBrick Constants
const String TEMPLATE_BRICK_ATTR = "attribute";
const String TEMPLATE_BRICK_TYPE = "brickType";
const String TEMPLATE_BRICK_DECORATION = "decoration";
const String PARENT_BRICK_CHILDREN = "children_bricks";
const String TEMPLATE_BRICK_LABEL = "label";

// Brick Constants
const String BRICK_IS_REQ = "is_required";
const String BRICK_TEXT_MAX_LEN = "max_len";
const String BRICK_TEXT_MIN_LEN = "min_len";
const String BRICK_TEXT_LINES = "lines";
const String BRICK_TEXT_LINE_LIMIT = "line_limit";
const String BRICK_TEXT_IS_INPUT_TYPE_NUMBER = "is_number";
const String BRICK_MAX_DATETIME = "max_dateTime";
const String BRICK_MIN_DATETIME = "min_dateTime";
const String BRICK_DATETIME_INPUT_TYPE = "dateTime_input_type";
const String BRICK_CHIP_CHOICES = "chip_choices";
const String BRICK_DROPDOWN_CHOICES = "dropdown_choices";
const String TITLE_BRICK_TEXT = "title_brick_text";
const String TITLE_BRICK_SIZE = "title_brick_size";
const String DATE_TIME_WIDTH = "date_time_width";
const String TABLE_BRICK_ROW_COUNT = "table_row_count";
const String TABLE_BRICK_SHOW_COLUMNS = "table_show_columns";
const String PERMISSION_CAN_EDIT = "permission_can_edit";
const String BRICK_READ_ONLY_TEXT = "read_only_text";
const String BRICK_SELECTED_MIN_VALUE = "selected_min_value";
const String BRICK_SELECTED_MAX_VALUE = "selected_max_value";
const String BRICK_INITAL_VALUE = "initial_value";
const String BRICK_DIVISIONS = "divisions";
const String FIELD_NAME = "read_only_field_name";
const String EMPTY_BRICK_LINES = "number_of_empty_lines";
const String ENTITY_SOURCE_ENUM = "read_only_data_source";

const String DROPDOWN_FIELD_NAME = "dropdown_field_name";
const String DROPDOWN_ENTITY_SOURCE_ENUM = "dropdown_data_source";

// Report Constants
const String REPORTS_COLLECTION_NAME = "Reports";
const String REPORT_NAME = "name";
const String REPORT_ATTR = "attributeValues";
const String REPORT_TEMPLATE = "template";
const String REPORT_CREATOR = "creator";
const String REPORT_LAST_EDITOR = "lastEditor";

// Plot Constants
const String PLOT_COLLECTION_NAME = "Plots";
const String PLOT_NAME = "שם";
const String PLOT_SITE_ID = 'אתר';
const String PLOT_STRIPS = "סטריפים";
const String PLOT_ID = "חלקה";

// Strip Constants

const String STRIP_COLLECTION_NAME = "Strips";
const String STRIP_NAME = "שם";
const String STRIP_TYPE = "סוג";
const String STRIP_PLOT_ID = "חלקה";
const String STRIP_NOTES = "הערות";
const String STRIP_FIRST_JOB = "פעולה ראשונה";
const String STRIP_SECOND_JOB = "פעולה שנייה";
const String STRIP_THIRD_JOB = "פעולה שלישית";

const String STRIP_STATUS = "סטאטוס";
const String STRIP_MINE_COUNT = "מספר מוקשים";
const String STRIP_DEPTH_COUNT = "מספר מטרות עומק";
const String STRIP_CURRENT_EMPLOYEE = " מפנה נוכחי";

// Strip Status Constants
const String STRIP_STATUS_NONE = "טרם התחיל";
const String STRIP_STATUS_FIRST = "ראשונה";
const String STRIP_STATUS_FIRST_DONE = "סיום ראשונה";
const String STRIP_STATUS_SECOND = "שנייה";
const String STRIP_STATUS_SECOND_DONE = "סיום שנייה";
const String STRIP_STATUS_IN_REVIEW = "ביקורת";
const String STRIP_STATUS_FINISHED = "סיום";

// StripJob Constants
const String STRIP_JOB_EMPLOYEE_ID = "מזהה מפנה";
const String STRIP_JOB_EMPLOYEE_NAME = "שם מפנה";
const String STRIP_JOB_MODIFIED_DATE = "עדכון אחרון";
const String STRIP_JOB_IS_DONE = "גמור";

// StripJobType Constants
const String STRIP_JOB_TYPE_UPEX = "UPEX";
const String STRIP_JOB_TYPE_REGULAR = "רגיל";

// ArrangementType Constants
const String ARRANGEMENT_TYPE_DRIVE = "סידור נסיעה";
const String ARRANGEMENT_TYPE_WORK = "סידור עבודה";

// Arrangement Constants
const String DRIVE_ARRANGEMENT_TITLE = "סידורי נסיעה";
const String WORK_ARRANGEMENT_TITLE = "סידורי עבודה";
const String A_DATE = "תאריך";
const String A_LAST_EDITOR = "עורך אחרון";
const String A_ARRANGEMENT = "סידור עבודה";
const String A_FREE_TEXT_INFO = "פירוט";

const String HIVE_PROJECT_ID_KEY = "projectId";

// Projects
const String PROJECT_NAME = "שם";
const String PROJECT_IS_ACTIVE = "פעיל";
const String PROJECT_EMPLOYEES = "עובדים";
const String PROJECT_MANAGER_ID = "מנהל";
const String PROJECT_IMAGE_URL = "קישור תמונה";
const String PROJECT_EMPLOYER = "מעסיק";
const String PROJECT_IMAGE_PATH = "קישור לקובץ";

//Data Gateway Constants

const TEST_PROJECT = "test_project";

const String WORK_ARRANGEMENT_PATH = "WorkArrangements";
const String DRIVE_ARRANGEMENT_PATH = "DriveArrangements";

const TEST_WORK_ARRANGEMENT = "test_work_arrangement";
const TEST_DRIVER_ARRANGEMENT = "test_driver_arrangement";

const String PROJECTS = "Projects";
const DONE = "DONE";
const FAIL = "FAIL";

const PASSWORD_MIN_LENGTH = 8;
const PASSWORD = "password";

const ISO_PHONE_CODE = 'IL';

const REGISTER_REQUIRED = "שדה זה הכרחי להרשמה";
const MIN_PASS_LENGTH_MSG = "סיסמא חייבת להיות באורך של 8 תווים לפחות";

const LIST_DELIMITER = ", ";

/// color of text on buttons of forms
const FORM_SUBMIT_TEXT_COLOR = Colors.white;

const HEBREW_REGEXP = r'[\u0590-\u05fe]';
const PARENTHESES_REGEXP = r'[\(\)\[\]\{\}]';
const SPECIAL_CASE_REGEXP =
    r'[\w\(\)\[\]\{\}]'; // english letters and digits + parentheses
const ENGLISH_REGEXP = r'[a-zA-Z]';
const NON_ENGLISH_REGEXP = r'[^a-zA-Z]*';

const String CURRENT_USER = 'currentUser';

const String ARRANGEMENT = 'arrangement';

const String EMPLOYMENT_MANAGER = 'מנהל עבודה';
const LOGO_IEOD_ASSET = "assets/images/IEOD_LOGO.jpeg";
const LOGO_IMAG_ASSET = "assets/images/IMAG_LOGO.jpeg";

const TEXT_DEFAULT_ROW_LIMIT = 70;

const SHORT_TEXT_DEFAULT_ROW_LIMIT = 20;