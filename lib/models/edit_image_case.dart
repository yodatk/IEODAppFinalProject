///
/// Represents a use case for editing a Entity with an image.
///
enum EditImageCase {
  NO_CHANGE, // don't change the image of the entity
  NEW_IMAGE, // update the image of the entity with the one that was given
  DELETE_IMAGE, // delete the image from the entity
}
