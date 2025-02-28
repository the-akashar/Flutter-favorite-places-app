import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }

}

class _ImageInputState extends State<ImageInput>{

  File? _selectedImage;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera ,
      maxWidth: double.infinity,
      maxHeight: double.infinity
       );

    if(pickedImage == null){
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);

  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
        icon: const Icon(Icons.camera),
        onPressed: _takePicture, 
        label: const Text('Take Picture'));

        if(_selectedImage != null){
          content = Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          // ignore: deprecated_member_use
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        )
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }

}