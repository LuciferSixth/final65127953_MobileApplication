import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'plant_detail_page.dart'; // Import หน้าแสดงรายละเอียดพรรณไม้
import 'web/database_helper.dart'; // Import DatabaseHelper สำหรับการดึงข้อมูล

class HomePage extends StatelessWidget {
  final Database database; // เพิ่มแอตทริบิวต์ Database
  final DatabaseHelper databaseHelper = DatabaseHelper.instance; // สร้าง instance ของ DatabaseHelper

  HomePage({Key? key, required this.database}) : super(key: key); // ปรับปรุง constructor

  // ดึงข้อมูลพรรณไม้รวมถึงส่วนประกอบและการใช้ประโยชน์
  Future<List<Map<String, dynamic>>> _fetchPlants() async {
    try {
      return await databaseHelper.queryAllPlants(); // ใช้ฟังก์ชันจาก DatabaseHelper
    } catch (e) {
      print("Error fetching plants: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plant Collection',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No plants found.'));
          }

          final plants = snapshot.data!;

          return ListView.separated(
            itemCount: plants.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final plant = plants[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  leading: _buildPlantImage(plant['plantImage']),
                  title: Text(plant['plantName']),
                  subtitle: Text(
                      'Scientific Name: ${plant['plantScientific']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantDetailPage(
                          plantData: plant,
                          database: database, // ส่ง Database Instance
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.green[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'All Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Plant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break; // หน้า home "All Plants" (หน้าปัจจุบัน)
            case 1:
              Navigator.pushNamed(context, '/addPlant', arguments: database);
              break;
            case 2:
              Navigator.pushNamed(context, '/search', arguments: database);
              break;
          }
        },
      ),
    );
  }

  // สร้างฟังก์ชันสำหรับการแสดงภาพพรรณไม้
  Widget _buildPlantImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.local_florist, size: 50, color: Colors.grey);
    }
    return Image.network(
      imagePath, // ใช้ URL ของรูปภาพ
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }
}
