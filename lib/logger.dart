import 'package:logger/logger.dart';

final Logger logger = Logger();

///
/// Concat all given [messages] to a single [String] with '\n' between each message
///
String concatMessages(List<String> messages) => messages.fold(
    "", (String previousValue, String msg) => "$previousValue\n$msg");

///
/// Print [msg] in debug level
///
debug(String msg) => logger.d(msg);

///
/// Print [msg] as verbose level
///
verbose(String msg) => logger.v(msg);

///
/// Print [msg] as info level
///
info(String msg) => logger.i(msg);

///
/// Print [msg] as warning level
///
warning(String msg) => logger.w(msg);

///
/// Print [msg] as error level
///
error(String msg) => logger.e(msg);

///
/// Print [msg] as critical level
///
critical(String msg) => logger.wtf(msg);

///
/// Print [messages] in debug level, with new line between each message
///
debugList(List<String> messages) => logger.d(concatMessages(messages));

///
/// Print [messages] as verbose level, with new line between each message
///
verboseList(List<String> messages) => logger.v(concatMessages(messages));

///
/// Print [messages] as info level, with new line between each message
///
infoList(List<String> messages) => logger.i(concatMessages(messages));

///
/// Print [messages] as warning level, with new line between each message
///
warningList(List<String> messages) => logger.w(concatMessages(messages));

///
/// Print [messages] as error level, with new line between each message
///
errorList(List<String> messages) => logger.e(concatMessages(messages));

///
/// Print [messages] as critical level, with new line between each message
///
criticalList(List<String> messages) => logger.wtf(concatMessages(messages));
