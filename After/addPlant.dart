import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'web/database_helper.dart';

class AddPlantPage extends StatefulWidget {
  final Database database;

  AddPlantPage({required this.database});

  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _plantScientificController = TextEditingController();
  final TextEditingController _plantImageURLController = TextEditingController();
  final TextEditingController _landUseDescriptionController = TextEditingController();
  final TextEditingController _landUseTypeDescriptionController = TextEditingController();

  String? _selectedComponent;
  String? _selectedIcon;
  String? _selectedLandUseType;

  List<String> components = ['Leaf', 'Flower', 'Fruit', 'Stem', 'Root'];
  List<String> landUseTypes = ['Food', 'Medicine', 'Insecticide', 'Construction', 'Culture', 'อื่นๆ'];

  @override
  void dispose() {
    _plantNameController.dispose();
    _plantScientificController.dispose();
    _plantImageURLController.dispose();
    _landUseDescriptionController.dispose();
    _landUseTypeDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _addPlant() async {
    final plantName = _plantNameController.text;
    final plantScientific = _plantScientificController.text;
    final plantImageURL = _plantImageURLController.text;

    if (plantName.isEmpty || plantScientific.isEmpty || plantImageURL.isEmpty) {
      _showErrorDialog('Please fill all the fields');
      return;
    }

    int plantID = await DatabaseHelper.instance.insertPlant({
      'plantName': plantName,
      'plantScientific': plantScientific,
      'plantImage': plantImageURL,
    });

    if (plantID > 0) {
      // ตรวจสอบว่าเพิ่มพรรณไม้สำเร็จ
      if (_selectedComponent != null && _selectedIcon != null) {
        int componentID = await DatabaseHelper.instance.insertPlantComponent({
          'componentName': _selectedComponent,
          'componentIcon': _selectedIcon,
        });

        if (componentID > 0) {
          // ตรวจสอบว่าเพิ่มคอมโพเนนต์สำเร็จ
          if (_selectedLandUseType != null && _landUseDescriptionController.text.isNotEmpty) {
            await DatabaseHelper.instance.insertLandUse({
              'LandUseDescription': _landUseDescriptionController.text,
              'LandUseTypeDescription': _landUseTypeDescriptionController.text,
              'plantID': plantID,
              'componentID': componentID,
            });
          }
        }
      }

      _clearInputs();
      _showSuccessDialog('Plant added successfully');
    } else {
      _showErrorDialog('Failed to add plant. Please try again.');
    }
  }

  void _clearInputs() {
    _plantNameController.clear();
    _plantScientificController.clear();
    _plantImageURLController.clear();
    _landUseDescriptionController.clear();
    _landUseTypeDescriptionController.clear();
    setState(() {
      _selectedComponent = null;
      _selectedIcon = null;
      _selectedLandUseType = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _plantNameController,
              decoration: InputDecoration(labelText: 'Plant Name'),
            ),
            TextField(
              controller: _plantScientificController,
              decoration: InputDecoration(labelText: 'Scientific Name'),
            ),
            TextField(
              controller: _plantImageURLController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            DropdownButton<String>(
              value: _selectedComponent,
              hint: Text('Select Component'),
              items: components.map((component) {
                return DropdownMenuItem(
                  value: component,
                  child: Text(component),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedComponent = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedLandUseType,
              hint: Text('Select Land Use Type'),
              items: landUseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLandUseType = value;
                });
              },
            ),
            TextField(
              controller: _landUseDescriptionController,
              decoration: InputDecoration(labelText: 'Land Use Description'),
            ),
            TextField(
              controller: _landUseTypeDescriptionController,
              decoration: InputDecoration(labelText: 'Land Use Type Description'),
            ),
            ElevatedButton(
              onPressed: _addPlant,
              child: Text('Add Plant'),
            ),
          ],
        ),
      ),
    );
  }
}
