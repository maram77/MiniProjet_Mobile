import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:student_isi_app/RadioButtonField.dart';

class DynamicForm extends StatefulWidget {
  final DocumentSnapshot formDefinition;

  DynamicForm({required this.formDefinition});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  String? uploadedFileName;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> formData = widget.formDefinition.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> formFields = List<Map<String, dynamic>>.from(formData['fields']);
    return Scaffold(
      appBar: AppBar(
        title: Text(formData['title'] ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: formFields.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> fieldData = formFields[index];
            String fieldType = fieldData['name'];
            switch (fieldType) {
              case 'Text Field':
                return buildTextField(fieldData['title'] ?? '');
              case 'Date Field':
                return buildDateField(fieldData['title'] ?? '');
              case 'Number Field':
                return buildNumberField(fieldData['title'] ?? '');
              case 'Dropdown Field':
                return buildDropdownField(fieldData['title'] ?? '', fieldData['options']);
              case 'Radio Buttons Field':
                return RadioButtonsField(title: fieldData['title'] ?? '', options: fieldData['options']);
              case 'Upload File':
                return buildUploadFileField(fieldData['title'] ?? '');
              default:
                return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget buildTextField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: title),
      ),
    );
  }

  Widget buildNumberField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: title),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget buildDateField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Builder(
        builder: (BuildContext context) {
          return InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
            },
            child: ListTile(
              title: Text(title),
              trailing: Icon(Icons.calendar_today),
            ),
          );
        },
      ),
    );
  }

  Widget buildDropdownField(String title, List<dynamic> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: title),
        items: options.map<DropdownMenuItem<String>>((option) {
          return DropdownMenuItem<String>(
            value: option.toString(),
            child: Text(option.toString()),
          );
        }).toList(),
        onChanged: (value) {
          // Handle dropdown value change
        },
      ),
    );
  }

  Widget buildUploadFileField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();

              if (result != null) {
                PlatformFile file = result.files.first;
                setState(() {
                  uploadedFileName = file.name;
                });
              } else {
                print('File picking canceled');
              }
            },
            child: Text(uploadedFileName ?? 'Upload File'),
          ),
        ],
      ),
    );
  }
}
