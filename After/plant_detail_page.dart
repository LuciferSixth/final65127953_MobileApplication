import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlantDetailPage extends StatefulWidget {
  final Map<String, dynamic> plantData;
  final Database database; // เพิ่ม database เพื่อใช้ในการแก้ไขและลบข้อมูล

  PlantDetailPage({required this.plantData, required this.database});

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  // ฟังก์ชันสำหรับแก้ไขข้อมูลพรรณไม้
  Future<void> _editPlant() async {
    final TextEditingController nameController =
    TextEditingController(text: widget.plantData['plantName']);
    final TextEditingController scientificController =
    TextEditingController(text: widget.plantData['plantScientific']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Plant Name'),
              ),
              TextField(
                controller: scientificController,
                decoration: InputDecoration(labelText: 'Scientific Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด popup โดยไม่บันทึก
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // อัปเดตข้อมูลพรรณไม้ในฐานข้อมูล
                await widget.database.update(
                  'plant',
                  {
                    'plantName': nameController.text,
                    'plantScientific': scientificController.text,
                  },
                  where: 'plantID = ?',
                  whereArgs: [widget.plantData['plantID']],
                );

                setState(() {
                  widget.plantData['plantName'] = nameController.text;
                  widget.plantData['plantScientific'] = scientificController.text;
                });

                Navigator.of(context).pop(); // ปิด popup หลังจากบันทึกเสร็จ
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับลบข้อมูลพรรณไม้
  Future<void> _deletePlant() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this plant?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด popup
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // ลบข้อมูลพรรณไม้จากฐานข้อมูล
                await widget.database.delete(
                  'plant',
                  where: 'plantID = ?',
                  whereArgs: [widget.plantData['plantID']],
                );

                Navigator.of(context).pop(); // ปิด popup หลังลบเสร็จ
                Navigator.of(context).pop(); // กลับไปหน้าแรก
              },
              child: Text('Delete'),
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
        title: Text(
          widget.plantData['plantName'],
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.plantData['plantImage'], // ใช้ URL ของรูปภาพ
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              'Scientific Name: ${widget.plantData['plantScientific']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Component: ${widget.plantData['componentName'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Land Use Type: ${widget.plantData['LandUseTypeName'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Description: ${widget.plantData['LandUseDescription'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _editPlant, // เรียกฟังก์ชันแก้ไขเมื่อคลิกปุ่ม
                  icon: Icon(Icons.edit),
                  label: Text('Edit'),
                ),
                ElevatedButton.icon(
                  onPressed: _deletePlant, // เรียกฟังก์ชันลบเมื่อคลิกปุ่ม
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
