import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'plant_detail_page.dart';

class SearchPage extends StatefulWidget {
  final Database database;

  SearchPage({required this.database});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _plants = [];
  List<Map<String, dynamic>> _filteredPlants = [];

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  // Fetch all plants from the database
  Future<void> _fetchPlants() async {
    try {
      final plants = await widget.database.rawQuery('''
        SELECT plant.plantID, plant.plantName, plant.plantScientific, plant.plantImage,
               plantComponent.componentName, plantComponent.componentIcon,
               LandUseType.LandUseTypeName, LandUseType.LandUseTypeDescription, LandUse.LandUseDescription
        FROM plant
        LEFT JOIN LandUse ON plant.plantID = LandUse.plantID
        LEFT JOIN plantComponent ON plantComponent.componentID = LandUse.componentID
        LEFT JOIN LandUseType ON LandUse.LandUseTypeID = LandUseType.LandUseTypeID
      ''');

      setState(() {
        _plants = plants;
        _filteredPlants = plants;
      });
    } catch (e) {
      print("Error fetching plants: $e");
    }
  }

  // Function to filter plants based on the search query
  void _filterPlants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlants = _plants;
      } else {
        _filteredPlants = _plants.where((plant) =>
        plant['plantName'].toLowerCase().contains(query.toLowerCase()) ||
            plant['LandUseTypeName'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Plants'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterPlants, // Call this function every time a search query is typed
              decoration: InputDecoration(
                labelText: 'Search by name or type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredPlants.isEmpty
                ? Center(child: Text('No plants found.'))
                : ListView.separated(
              itemCount: _filteredPlants.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final plant = _filteredPlants[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: Image.network(
                      plant['plantImage'], // Load image from URL
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(plant['plantName']),
                    subtitle: Text('Scientific Name: ${plant['plantScientific']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDetailPage(plantData: plant, database: widget.database), // Use widget.database here
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
