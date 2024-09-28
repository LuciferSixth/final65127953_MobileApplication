import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'web/database_helper.dart'; // Update this to your project structure
import 'homepage.dart';
import 'plant_detail_page.dart';
import 'plant_component_page.dart';
import 'land_use_page.dart';
import 'search_page.dart';
import 'addPlant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Database? database;

  // Initialize the database and handle potential errors
  try {
    database = await DatabaseHelper.instance.database;
  } catch (e) {
    print('Database initialization error: $e');
    return; // Exit if the database cannot be initialized
  }

  runApp(MyApp(database: database!)); // Use non-null assertion
}

class MyApp extends StatelessWidget {
  final Database database;

  MyApp({required this.database}); // Use named parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Database App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(database: database), // Pass the database instance here
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/components':
            return MaterialPageRoute(
              builder: (context) => PlantComponentPage(database: database),
            );
          case '/landUses':
            return MaterialPageRoute(
              builder: (context) => LandUsePage(database: database),
            );
          case '/search':
            return MaterialPageRoute(
              builder: (context) => SearchPage(database: database),
            );
          case '/addPlant':
            return MaterialPageRoute(
              builder: (context) => AddPlantPage(database: database),
            );
          case '/plantDetail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PlantDetailPage(
                plantData: args['plantData'],
                database: database,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => HomePage(database: database), // Default route
            );
        }
      },
    );
  }
}
