import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(home: ImagePickerWithCupertinoSheet()));
}

class ImagePickerWithCupertinoSheet extends StatefulWidget {
  @override
  _ImagePickerWithCupertinoSheetState createState() =>
      _ImagePickerWithCupertinoSheetState();
}

class _ImagePickerWithCupertinoSheetState
    extends State<ImagePickerWithCupertinoSheet> {
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showImageOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: Text('選擇圖片來源'),
            actions: [
              CupertinoActionSheetAction(
                child: Text('從相簿選擇'),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              CupertinoActionSheetAction(
                child: Text('使用相機'),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('取消'),
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('圖片選擇器')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30,
            onPressed: () => _showImageOptions(context),
          ),
          if (_selectedImage != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Image.file(
                _selectedImage!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
