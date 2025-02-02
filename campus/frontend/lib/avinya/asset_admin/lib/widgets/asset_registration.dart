import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gallery/avinya/asset_admin/lib/data/asset.dart';

class AssetRegistrationForm extends StatefulWidget {
  const AssetRegistrationForm({super.key});

  @override
  State<AssetRegistrationForm> createState() => _AssetRegistrationFormState();
}

class _AssetRegistrationFormState extends State<AssetRegistrationForm> {
  String? selectedAssetType;
  final TextEditingController assetNameController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();
  final TextEditingController warrantyController = TextEditingController();
  PlatformFile? uploadedFile;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        uploadedFile = result.files.first;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    bool isNumeric = false,
    bool isDateField = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric
            ? TextInputType.number
            : isDateField
                ? TextInputType.datetime
                : isMultiline
                    ? TextInputType.multiline
                    : TextInputType.text,
        maxLines: isMultiline ? 3 : 1,
        readOnly: isDateField,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: isDateField
              ? IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null && controller != null) {
                      controller.text =
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (selectedAssetType == null) return const SizedBox();

    switch (selectedAssetType) {
      case "mobile":
        return Column(
          children: [
            _buildTextField(
              label: "Brand",
              hint: "Enter Mobile Brand",
            ),
            _buildTextField(
              label: "Model Number",
              hint: "Enter Model Number",
            ),
          ],
        );
      case "laptops":
        return Column(
          children: [
            _buildTextField(
              label: "Brand",
              hint: "Enter Laptop Brand",
            ),
            _buildTextField(
              label: "Model Number",
              hint: "Enter Model Number",
            ),
            _buildTextField(
              label: "Specifications",
              hint: "Enter Specifications (e.g., Processor, RAM, SSD)",
              isMultiline: true,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Warranty/Support Document",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (uploadedFile != null)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(uploadedFile!.name),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    uploadedFile = null;
                  });
                },
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload File"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            foregroundColor: Colors.black,
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Asset Registration",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Asset Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedAssetType,
                items: const [
                  DropdownMenuItem(value: "mobile", child: Text("Mobile")),
                  DropdownMenuItem(value: "laptops", child: Text("Laptops")),
                  DropdownMenuItem(
                      value: "electronics", child: Text("Electronics")),
                  DropdownMenuItem(
                      value: "furniture", child: Text("Furniture")),
                  DropdownMenuItem(
                      value: "accessories", child: Text("Accessories")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedAssetType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: assetNameController,
                label: "Asset Name",
                hint: "Enter Asset Name",
              ),
              _buildTextField(
                controller: serialNumberController,
                label: "Serial Number",
                hint: "Enter Serial Number",
              ),
              _buildTextField(
                controller: purchaseDateController,
                label: "Purchase Date",
                hint: "Select Purchase Date",
                isDateField: true,
              ),
              _buildTextField(
                controller: purchasePriceController,
                label: "Purchase Price",
                hint: "Enter Purchase Price",
                isNumeric: true,
              ),
              _buildDynamicFields(),
              const SizedBox(height: 16),
              _buildUploadSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle form submission
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Register Asset"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
