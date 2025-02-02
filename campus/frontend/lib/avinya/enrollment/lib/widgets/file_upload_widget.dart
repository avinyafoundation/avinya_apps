import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';

class FileUploadWidget extends StatefulWidget {
  final int  userDocumentId;
  final String documentType;
  final String documentTypeLabel;
  String?  stringImage;

  FileUploadWidget({
    Key? key,
    required this.userDocumentId,
    required this.documentType,
    required this.documentTypeLabel,
    this.stringImage
    })
      : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  Uint8List? _selectedImageBytes;
  String? _validationError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please upload the required file for "${widget.documentTypeLabel}".',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 20),
        _buildFileInputField(
          label: widget.documentTypeLabel,
          imageBytes:_selectedImageBytes !=null ? _selectedImageBytes
              : widget.stringImage == null ? null: base64Decode(widget.stringImage!),
          fieldKey: widget.documentTypeLabel,
          onTap: () async {
            final imageBytes = await _pickFile();
            if (imageBytes != null) {
              var documentDetails = {
                "id": widget.userDocumentId,
                "document_type": widget.documentType
              };
              await uploadFile(imageBytes, documentDetails);
              setState(() {
                _selectedImageBytes = imageBytes;
                _validationError = null; // Clear any errors
              });
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFileInputField({
    required String label,
    required Uint8List? imageBytes,
    required String fieldKey,
    required void Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 330,
              height: 90,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  imageBytes == null
                      ? const Icon(
                          Icons.add_a_photo_rounded,
                          size: 35.0,
                          color: Color(0xFF000080),
                        )
                      : Image.memory(
                          imageBytes,
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                        ),
                  const SizedBox(width: 30.0),
                  RichText(
                    text: TextSpan(
                      text: label,
                      style: const TextStyle(
                        color: Color(0xFF000080),
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_validationError != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Text(
              _validationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<Uint8List?> _pickFile() async {
    if (kIsWeb) {
      // For Web: Use FilePicker
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        return result.files.single.bytes;
      }
    } else {
      // For Mobile: Use ImagePicker
      final XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    }
    return null;
  }
}
