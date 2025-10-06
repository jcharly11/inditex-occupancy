import 'package:inditex_occupancy/data/models/enrich_firebase_model.dart';
import 'package:inditex_occupancy/data/models/mqtt_data_firebase_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbSqliteHelper {
  static final DbSqliteHelper instance = DbSqliteHelper._init();
  static Database? db;

  DbSqliteHelper._init();

  

  Future<Database> get database async {
    if (db != null) return db!;
    db = await initDB('inditex_occupancy.db');
    return db!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: createDB,
    );
  }

  Future createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        idEvent INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL,
        accountNumber TEXT,
        storeId TEXT,
        eventId TEXT,
        silent INTEGER,
        groupId TEXT,
        timestamp INTEGER,
        deviceId TEXT,
        deviceModel TEXT,
        technology TEXT,
        doorName TEXT,
        UNIQUE(uuid, timestamp) ON CONFLICT IGNORE
      )
    ''');
     
    await db.execute('''
      CREATE TABLE enrich (
        enrichId INTEGER PRIMARY KEY AUTOINCREMENT,
        idEvent INTEGER,
        uuid TEXT,
        category TEXT,
        description TEXT,
        epc TEXT,
        imageUrl TEXT,
        price TEXT,
        sku TEXT,
        gtin TEXT    
      )
    ''');

    await db.execute('''
      CREATE TABLE mqttdata (
        idEvent INTEGER,
        key TEXT,
        type TEXT,
        value TEXT    
      )
    ''');
  }

  Future<int> 
  saveEvents(Map<String, dynamic> row, List<EnrichFirebaseModel> enrich, List<MqttDataFirebaseModel> mqttData) async {
    final db = await instance.database;
    if(row["eventId"]!="people_counting"){
      bool insert= true;
      for (var item in mqttData){
        if(item.value[0] =="Jammer cleared"){
          insert= false;
          break;
        }
      }

      if(insert){
        final id= await db.insert('events', row, conflictAlgorithm: ConflictAlgorithm.ignore);
        
        if(id > 0){
          for(var item in enrich){
            await saveEnrichData({
              "IdEvent": id,
              "uuid": row["uuid"],
              "category": item.category,
              "description": item.description,
              "epc": item.epc,
              "imageUrl": item.imageUrl,
              "price": item.price,
              "sku": item.sku,
              "gtin": item.gtin,
            });
          }
          for(var item in mqttData){
            
            await saveMqttData({
              "idEvent":id,
              "key": item.key,
              "type": item.type,
              "value": item.value[0]
            });
          }
        }
        return id;
      }
    }
    return 0;
  }



  Future<int> saveEnrichData(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('enrich', row);
  }

  Future<int> saveMqttData(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('mqttdata', row);
  }

 

  Future<List<Map<String, dynamic>>> getEventsByDate(DateTime startDate, DateTime endDate, String groupId) async {
    final startMillis = startDate.millisecondsSinceEpoch;
    final endMillis = endDate.millisecondsSinceEpoch;

    final db = await instance.database;

    return await db.query(
      'events',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startMillis, endMillis],
      orderBy: 'timestamp DESC',
    );
    
    
   
  }

  Future<List<Map<String, dynamic>>> getEnrichData(int id, String uuid) async {
    final db = await instance.database;
    final query= await db.query(
      'enrich',
      where: 'idEvent = ?',
      whereArgs: [id], 
    );

    return query;
  }

  Future<List<Map<String, dynamic>>> getMqttData(int id) async {
    final db = await instance.database;
    final query= await db.query(
      'mqttdata',
      where: 'idEvent = ?',
      whereArgs: [id], 
    );

    return query;
  }


  Future<int> deleteEvents() async {
    final db = await instance.database;
    return await db.delete('events');
  }

  Future<int> deleteEnrich() async {
    final db = await instance.database;
    return await db.delete('enrich');
  }

  Future<int> deleteMqttData() async {
    final db = await instance.database;
    return await db.delete('mqttdata');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
