import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class AddPicture extends StatefulWidget {
  final Function selectedImage;

  AddPicture({required this.selectedImage});
  @override
  State<AddPicture> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  XFile? _storedImage;

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image == null) {
      return;
    }
    setState(() {
      _storedImage = image;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
    widget.selectedImage(savedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 0.5),
            ),
            child: _storedImage != null
                ? Image.file(
              //_storedImage,
              File(_storedImage!.path),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              width: double.infinity,
            )
                :  const Center(
                  child: Text(
              'No Image Taken',
              textAlign: TextAlign.center,
            ),
                ),
          ),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(onPressed: _takePicture, icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Take Picture'),))
        ],
      )
    );
  }
}
