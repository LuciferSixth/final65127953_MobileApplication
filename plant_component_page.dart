import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlantComponentPage extends StatelessWidget {
  final Database database;

  PlantComponentPage({required this.database});

  Future<List<Map<String, dynamic>>> _fetchPlantComponents() async {
    try {
      return await database.query('plantComponent');
    } catch (e) {
      throw Exception('Failed to load components: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Components'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPlantComponents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading components: ${snapshot.error}'));
          } else {
            final components = snapshot.data ?? [];
            if (components.isEmpty) {
              return Center(child: Text('No components found.'));
            }
            return ListView.builder(
              itemCount: components.length,
              itemBuilder: (context, index) {
                final component = components[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/icons/${component['componentIcon']}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(component['componentName']),
                    subtitle: Text('Component ID: ${component['componentID']}'),
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
