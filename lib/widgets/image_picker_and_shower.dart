import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/style_constants.dart' as StyleConstants;

///
/// Widget to pick images from camera or gallery
///
class ImagePickerAndShower extends StatefulWidget {
  ///
  /// Function to activate when [pickedImage] file is picked. useful in bigger form or complicated view model classes
  ///
  final void Function(File pickedImage) imagePickFn;

  ///
  /// Function to activate when an picked image is dismissed. useful in bigger form or complicated view model classes
  ///
  final void Function() deleteImage;

  ///
  /// show the chosen image when the widget is building for the first time
  ///
  final ImageProvider oldImage;

  ImagePickerAndShower(this.imagePickFn, {this.oldImage, this.deleteImage});

  @override
  _ImagePickerAndShowerState createState() => _ImagePickerAndShowerState();
}

class _ImagePickerAndShowerState extends State<ImagePickerAndShower> {
  ///
  /// current image that was picked by the user
  ///
  File _pickedImage;

  ///
  /// [ImagePicker] object to get to the gallery or camera
  ///
  ImagePicker picker = new ImagePicker();

  void _pickImage(ImageSource source) async {
    final pickedImageFile = await picker.getImage(source: source);
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(_pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 120.0,
          width: 120.0,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 120.0,
                  width: 120.0,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    image: DecorationImage(
                      image: widget.oldImage != null && _pickedImage == null
                          ? widget.oldImage
                          : _pickedImage != null
                              ? FileImage(_pickedImage) as ImageProvider<Object>
                              : AssetImage(StyleConstants.PLACE_HOLDER_IMAGE),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 60,
                child: RaisedButton(
                  shape: const CircleBorder(),
                  color: Colors.white70,
                  child: const Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                    });
                    widget.imagePickFn(null);
                    if (widget.deleteImage != null) {
                      widget.deleteImage();
                    }
                  },
                ),
              ),
            ],
            overflow: Overflow.visible,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlatButton.icon(
              color: StyleConstants.primaryColor,
              textColor: Colors.white,
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.image_search),
              label: const Text(
                'גלריה',
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            FlatButton.icon(
              color: StyleConstants.primaryColor,
              textColor: Colors.white,
              //textColor: Theme.of(context).primaryColor,
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
              icon: const Icon(Icons.photo_camera),
              label: const Text(
                'מצלמה',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
