import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class LandUsePage extends StatelessWidget {
  final Database database;

  LandUsePage({required this.database});

  Future<List<Map<String, dynamic>>> _fetchLandUses() async {
    // ดึงข้อมูลการใช้ประโยชน์พรรณไม้พร้อมข้อมูลพรรณไม้และประเภทการใช้ประโยชน์
    return await database.rawQuery(''' 
      SELECT 
        LandUse.LandUseDescription, 
        LandUse.plantID, 
        LandUse.componentID,  // Corrected typo
        LandUse.LandUseTypeID, 
        plant.plantName, 
        plantComponent.componentName,
        LandUseType.LandUseTypeName 
      FROM 
        LandUse 
      LEFT JOIN 
        plant ON LandUse.plantID = plant.plantID 
      LEFT JOIN 
        plantComponent ON LandUse.componentID = plantComponent.componentID 
      LEFT JOIN 
        LandUseType ON LandUse.LandUseTypeID = LandUseType.LandUseTypeID
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Land Uses'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLandUses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading land uses: ${snapshot.error}'), // Improved error message
            );
          } else {
            final landUses = snapshot.data ?? [];
            return ListView.builder(
              itemCount: landUses.length,
              itemBuilder: (context, index) {
                final landUse = landUses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text('Description: ${landUse['LandUseDescription']}'),
                    subtitle: Text(
                      'Plant: ${landUse['plantName']}, Component: ${landUse['componentName']}\n'
                          'Type: ${landUse['LandUseTypeName']}',
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
