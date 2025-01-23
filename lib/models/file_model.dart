import 'dart:typed_data';

class FileModel {
  final String filename;
  final Uint8List fileBytes;

  FileModel({required this.filename, required this.fileBytes});
}
