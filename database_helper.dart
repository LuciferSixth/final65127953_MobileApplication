import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "plant_database.db";
  static final _databaseVersion = 7; // Incremented version

  // Tables
  static final tablePlant = 'plant';
  static final tablePlantComponent = 'plantComponent';
  static final tableLandUseType = 'LandUseType';
  static final tableLandUse = 'LandUse';

  // Columns for table plant
  static final columnPlantID = 'plantID';
  static final columnPlantName = 'plantName';
  static final columnPlantScientific = 'plantScientific';
  static final columnPlantImage = 'plantImage';

  // Columns for table plantComponent
  static final columnComponentID = 'componentID';
  static final columnComponentName = 'componentName';
  static final columnComponentIcon = 'componentIcon';

  // Columns for table LandUseType
  static final columnLandUseTypeID = 'LandUseTypeID';
  static final columnLandUseTypeName = 'LandUseTypeName';
  static final columnLandUseTypeDescription = 'LandUseTypeDescription';

  // Columns for table LandUse
  static final columnLandUseID = 'LandUseID';
  static final columnLandUseDescription = 'LandUseDescription';
  static final columnLandUseTypeIDFK = 'LandUseTypeID';
  static final columnPlantIDFK = 'plantID';
  static final columnComponentIDFK = 'componentID';

  // Singleton pattern for DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePlant (
        $columnPlantID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPlantName TEXT NOT NULL,
        $columnPlantScientific TEXT NOT NULL,
        $columnPlantImage TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePlantComponent (
        $columnComponentID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnComponentName TEXT NOT NULL,
        $columnComponentIcon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLandUseType (
        $columnLandUseTypeID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnLandUseTypeName TEXT NOT NULL,
        $columnLandUseTypeDescription TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLandUse (
        $columnLandUseID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnLandUseDescription TEXT NOT NULL,
        $columnLandUseTypeIDFK INTEGER NOT NULL,
        $columnPlantIDFK INTEGER NOT NULL,
        $columnComponentIDFK INTEGER NOT NULL,
        FOREIGN KEY ($columnPlantIDFK) REFERENCES $tablePlant($columnPlantID),
        FOREIGN KEY ($columnComponentIDFK) REFERENCES $tablePlantComponent($columnComponentID),
        FOREIGN KEY ($columnLandUseTypeIDFK) REFERENCES $tableLandUseType($columnLandUseTypeID)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      var result = await db.rawQuery('PRAGMA table_info($tableLandUse)');
      if (result.where((column) => column['name'] == columnComponentIDFK).isEmpty) {
        await db.execute('''
          ALTER TABLE $tableLandUse ADD COLUMN $columnComponentIDFK INTEGER;
        ''');
      }
    }
  }

  Future<List<Map<String, dynamic>>> queryAllPlants() async {
    Database db = await instance.database;
    return await db.query(tablePlant);
  }

  Future<int> insertPlant(Map<String, dynamic> plant) async {
    Database db = await instance.database;
    return await db.insert(tablePlant, plant);
  }

  Future<int> insertPlantComponent(Map<String, dynamic> component) async {
    Database db = await instance.database;
    return await db.insert(tablePlantComponent, component);
  }

  Future<int> insertLandUse(Map<String, dynamic> landUse) async {
    Database db = await instance.database;
    return await db.insert(tableLandUse, landUse);
  }
}
