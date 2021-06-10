///
/// Checks if a given [Iterable] is not null and not empty
///
bool isListExistsAndNotEmpty(Iterable toCheck) =>
    toCheck != null && toCheck.isNotEmpty;

///
/// Checks that a given [Iterable] is not null BUT it is empty
///
bool isListExistsAndEmpty(Iterable toCheck) =>
    toCheck != null && toCheck.isEmpty;
