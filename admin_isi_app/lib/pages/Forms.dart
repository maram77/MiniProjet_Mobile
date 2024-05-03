import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormBuilder extends StatefulWidget {
  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  List<Map<String, dynamic>> formFields = [];
  late DateTime selectedDate;
  int fieldCounter = 0;
  String? uploadedFileName;
  String? selectedFieldType;
  late List<String> dropdownItems;
  late List<String> radioOptions;
  String? selectedOption;
  TextEditingController formTitleController = TextEditingController();


  List<Map<String, dynamic>> fieldTypes = [
    {'name': 'Text Field', 'icon': Icons.text_fields},
    {'name': 'Date Field', 'icon': Icons.calendar_today},
    {'name': 'Dropdown Field', 'icon': Icons.arrow_drop_down_circle},
    {'name': 'Radio Buttons Field', 'icon': Icons.radio_button_checked},
    {'name': 'Number Field', 'icon': Icons.format_list_numbered},
    {'name': 'Upload File', 'icon': Icons.file_upload},
  ];

  // Map to store field type and corresponding widget creation function
  Map<String, Widget Function(int?)?> fieldWidgets = {};
  Map<String, String> fieldTitles = {};

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    radioOptions = ['Option 1', 'Option 2'];
    selectedOption = radioOptions.first;
    dropdownItems = ["Select option"];
    for (var fieldType in fieldTypes) {
      fieldTitles[fieldType['name']] = '';
    }
    fieldWidgets = {
      'Text Field': (index) => buildTextField(index),
      'Date Field': (index) => buildDateField(index),
      'Dropdown Field': (index) => buildDropdownField(index),
      'Radio Buttons Field': (index) => buildRadioButtonsField(index),
      'Number Field': (index) => buildNumberField(index),
      'Upload File': (index) => buildUploadFileField(index),
    };
  }

  Widget buildTextField(int? index) {
    return buildFieldWrapper(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Field ${index! + 1}',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          buildRemoveButton(index),
        ],
      ),
    );
  }

  Widget buildDateField(int? index) {
    return buildFieldWrapper(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Date Field ${index! + 1}'),
                  trailing: TextButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          buildRemoveButton(index),
        ],
      ),
    );
  }

  Widget buildDropdownField(int? index) {
    String title = fieldTitles['Dropdown Field'] ?? '';
    TextEditingController titleController = TextEditingController(text: title);
    String? selectedValue = dropdownItems.first;
    return buildFieldWrapper(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: DropdownButtonFormField<String>(
                    value: selectedValue,
                    onChanged: (value) {
                      print('Selected value: $value');
                      setState(() {
                        selectedValue = value;
                      });
                    },
                    items: dropdownItems.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              String? newOption = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  String? option;
                  return AlertDialog(
                    title: Text('Add Option'),
                    content: TextField(
                      onChanged: (value) {
                        option = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'New Option',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, option);
                        },
                        child: Text('Add'),
                      ),
                    ],
                  );
                },
              );

              if (newOption != null && newOption.isNotEmpty) {
                setState(() {
                  dropdownItems.add(newOption!);
                });
              }
            },
            icon: Icon(Icons.add),
          ),
          buildRemoveButton(index),
        ],
      ),
    );
  }

  Widget buildRadioButtonsField(int? index) {
    String title = fieldTitles['Radio Buttons Field'] ?? '';
    TextEditingController titleController = TextEditingController(text: title);
    if (radioOptions.isEmpty) {
      radioOptions = ['Option 1', 'Option 2'];
      selectedOption = radioOptions.first;
    }

    List<TextEditingController> optionControllers = [];
    for (int i = 0; i < radioOptions.length; i++) {
      optionControllers.add(TextEditingController(text: radioOptions[i]));
    }

    return buildFieldWrapper(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Radio Buttons Field ${index! + 1}'),
              buildRemoveButton(index),
            ],
          ),
          ...radioOptions.asMap().entries.map((entry) {
            int optionIndex = entry.key;
            String option = entry.value;
            return Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: Text(option),
                    value: option,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      print('Selected value: $value');
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    String? newOptionName = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String? option;
                        return AlertDialog(
                          title: Text('Change Option Name'),
                          content: TextField(
                            controller: optionControllers[optionIndex],
                            onChanged: (value) {
                              option = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Option ${optionIndex + 1}',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, option);
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );

                    if (newOptionName != null && newOptionName.isNotEmpty) {
                      setState(() {
                        radioOptions[optionIndex] = newOptionName;
                      });
                    }
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
            );
          }).toList(),
          Center(
            child: IconButton(
              onPressed: () async {
                String? newOption = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String? option;
                    return AlertDialog(
                      title: Text('Add Option'),
                      content: TextField(
                        onChanged: (value) {
                          option = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'New Option',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, option);
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );

                if (newOption != null && newOption.isNotEmpty) {
                  setState(() {
                    radioOptions.add(newOption!);
                    selectedOption = newOption;
                    optionControllers.add(TextEditingController(text: newOption));
                  });
                }
              },
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberField(int? index) {
    String title = fieldTitles['Number Field'] ?? '';
    TextEditingController titleController = TextEditingController(text: title);
    return buildFieldWrapper(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number Field ${index! + 1}',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ],
            ),
          ),
          buildRemoveButton(index),
        ],
      ),
    );
  }

  Widget buildUploadFileField(int? index) {
    String title = fieldTitles['Upload File'] ?? '';
    TextEditingController titleController = TextEditingController(text: title);
    return buildFieldWrapper(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Text(uploadedFileName ?? 'Upload File ${index! + 1}'),
                ),
              ],
            ),
          ),
          buildRemoveButton(index),
        ],
      ),
    );
  }

  void editTitle(String fieldType, String currentTitle) {
    TextEditingController titleController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Title'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  fieldTitles[fieldType] = titleController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRemoveButton(int? index) {
    return IconButton(
      onPressed: () {
        setState(() {
          formFields.removeAt(index!);
          for (int i = index; i < formFields.length; i++) {
            formFields[i]['counter'] = formFields[i]['counter'] - 1;
          }
          fieldCounter--;
        });
      },
      icon: Icon(Icons.remove),
    );
  }

  Widget buildFieldWrapper(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Form Builder'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                saveFormDataToFirestore();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1)
              ),
              child: Text(
                'Save Form Data',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField( // Text field for entering form title
              controller: formTitleController,
              decoration: InputDecoration(labelText: 'Form Title'),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: MediaQuery.of(context).size.width, // Full width
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: formFields.map<Widget>((field) {
                        if (fieldWidgets[field['name']] != null) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text(fieldTitles[field['name']] ?? ''),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      editTitle(field['name'], fieldTitles[field['name']] ?? '');
                                    },
                                  ),
                                ],
                              ),
                              buildFieldWrapper(
                                fieldWidgets[field['name']]!(field['counter']),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedFieldType,
              onChanged: (value) {
                setState(() {
                  selectedFieldType = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select a field type'),
                ),
                ...fieldTypes.map<DropdownMenuItem<String>>((fieldType) {
                  return DropdownMenuItem<String>(
                    value: fieldType['name'],
                    child: Row(
                      children: [
                        Icon(fieldType['icon']),
                        SizedBox(width: 8.0),
                        Text(fieldType['name']),
                      ],
                    ),
                  );
                }),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (selectedFieldType != null) {
                  TextEditingController titleController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Add title',
                          style: TextStyle(color: Color(0xFF0D47A1)),
                        ),
                        content: TextField(
                          controller: titleController,
                          decoration: InputDecoration(labelText: 'Title'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel',style: TextStyle(color: Color(0xFF0D47A1))),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                formFields.add({
                                  'name': selectedFieldType,
                                  'counter': fieldCounter,
                                });
                                fieldTitles[selectedFieldType!] = titleController.text;
                                selectedFieldType = null;
                                fieldCounter++;
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Confirm',style: TextStyle(color: Color(0xFF0D47A1))),
                          ),
                        ],
                      );
                    },
                  );
                } else {

                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1)
              ),
              child: Text(
                'Add Field',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void resetForm() {
    formTitleController.clear();
    formFields.clear();
    fieldCounter = 0;
    uploadedFileName = null;
    selectedFieldType = null;
    selectedDate = DateTime.now();
    radioOptions = ['Option 1', 'Option 2'];
    selectedOption = radioOptions.first;
    dropdownItems = ["Select option"];
    fieldTitles = {};
    for (var fieldType in fieldTypes) {
      fieldTitles[fieldType['name']] = '';
    }
  }

  void saveFormDataToFirestore() async {
    try {
      CollectionReference formCollection = FirebaseFirestore.instance.collection('formFields');
      Map<String, dynamic> formData = {
        'titleForm': formTitleController.text,
        'fields': formFields.map((field) {
          Map<String, dynamic> fieldData = {
            'name': field['name'],
            'title': fieldTitles[field['name']],
          };

          if (field['name'] == 'Dropdown Field') {
            fieldData['options'] = dropdownItems;
          } else if (field['name'] == 'Radio Buttons Field') {
            fieldData['options'] = radioOptions;
          }

          return fieldData;
        }).toList(),
      };

      await formCollection.add(formData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Form data saved successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Color(0xFF0D47A1), // Set background color to blue
          duration: Duration(seconds: 2),
        ),
      );
      print('Form data saved to Firestore successfully!');
      resetForm();
    } catch (error) {
      print('Error saving form data to Firestore: $error');
    }
  }

}
