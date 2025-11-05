


import 'package:inditex_occupancy/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs; // Firestore
import 'package:sembast_web/sembast_web.dart';

class DbSembastHelper {
  static final DbSembastHelper instance = DbSembastHelper._init();
  Database? _db;

  final _eventsGym = intMapStoreFactory.store('eventsGym');
  final _eventsAudit = intMapStoreFactory.store('eventsAudit');
  final _people = intMapStoreFactory.store('people');
  final _gifts = stringMapStoreFactory.store("gifts");

  DbSembastHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDB('inditex_occupancy.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final factory = databaseFactoryWeb;
    return await factory.openDatabase(filePath);
  }


  Future<int> saveEvent(Map<String, dynamic> row,List<dynamic> epcs, String type) async {
    final db = await database;

    final finder = Finder(filter: Filter.equals('uuid', row['uuid']));   
    RecordSnapshot<int, Map<String, Object?>>? existing;
    RecordSnapshot<int, Map<String, Object?>>? existingPeople; 

    if(type=="gym"){
      existing = await _eventsGym.findFirst(db, finder: finder);
    }
    else{
      existing = await _eventsAudit.findFirst(db, finder: finder);
    }
    existingPeople = await _people.findFirst(db, finder: finder);

    int key= 0;
    if (existing == null) {
      for(var epc in epcs){
        final idEmployee= epc.toString().substring(1,7);
        final ticketNumber= epc.toString().substring(7,9);
        bool isAdult= epc.toString().substring(9,10) == "1" ? true : false;

        final finalRow= {
          "uuid": row["uuid"],
          "timestamp": row["timestamp"],
          "epc": epc,
          "idEmployee": idEmployee,
          "ticketNumber": ticketNumber,
          "isAdult": isAdult,
          "doorName": row["doorName"]
        };

        if(type=="gym"){
          key = await _eventsGym.add(db, finalRow);
        }
        else{
          key = await _eventsAudit.add(db, finalRow);
        }


       
        if(existingPeople==null){
          
          final finalRowPeople= {
            "uuid": row["uuid"],
            "timestamp": row["timestamp"],
            "epc": epc,
            "idEmployee": idEmployee,
            "ticketNumber": ticketNumber,
            "isAdult": isAdult,
            "zone": type,
            "gift": false,
            "doorName": row["doorName"],
            "timestampGift": 0
          };
          await _people.add(db, finalRowPeople);

          var docs= await FirebaseService.peopleExists(idEmployee);
          if(docs.isEmpty){
            await FirebaseService.insertPeopleGift(idEmployee);
          }
          // else{
          //   for(var doc in docs){
          //     await FirebaseService.updatePeopleGift(doc.id);
          //   }
          // }
        }
      }
    }

    

    return key;
  }


  Future<int> savePeople(Map<String, dynamic> row) async {
    final db = await database;
    return await _people.add(db, row);
  }

  Future<int> updatePeople(String epc, String zone) async {
    final db = await database;
    final employee = await _people.findFirst(db, finder: Finder(filter: Filter.equals('epc', epc)));
    await employee!.ref.update(db, {"actualZone": zone});
    return 1;
  }

  

  Future<List<RecordSnapshot<int, Map<String, dynamic>>>> getEventsByDate(
      DateTime startDate, DateTime endDate, String type) async {
    final db = await database;
    final finder = Finder(
      filter: Filter.and([
        Filter.greaterThanOrEquals('timestamp', startDate.millisecondsSinceEpoch),
        Filter.lessThanOrEquals('timestamp', endDate.millisecondsSinceEpoch),
      ]),
      sortOrders: [
        SortOrder('idEmployee', true),
        SortOrder('ticketNumber', true)
      ],
    );
    final finderPeople = Finder(
      sortOrders: [
        SortOrder('idEmployee', true),
        SortOrder('ticketNumber', true)
      ],
    );
    if(type=="gym"){
      return await _eventsGym.find(db, finder: finder);
    }
    else if(type=="audit"){
      return await _eventsAudit.find(db, finder: finder);
    }
    else{
      return await _people.find(db, finder: finderPeople);
    }
  }

  

  // ------------------ DELETE ------------------


  
// Future<void> deteteEventsBeforeToday() async {
//   final db = await database;
  

//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   final timestampToday = today.millisecondsSinceEpoch;

//   final filtro = Filter.lessThan('timestamp', timestampToday);

//   final regsGym = await _eventsGym.find(db, finder: Finder(filter: filtro));
//   final regsAudit = await _eventsAudit.find(db, finder: Finder(filter: filtro));

//   // Borra cada registro
//   for (var registro in registros) {
//     await store.record(registro.key).delete(db);
//   }

//   print('Registros anteriores a hoy eliminados.');
// }


  Future<int> deleteEvents() async {
    final db = await database;
    return await _people.delete(db);
  }


  Future close() async {
    await _db?.close();
  }


  Future<void> insertInitialData() async {
    final db = await database;
    final existing = await _gifts.find(db);
    if (existing.isNotEmpty) return;

    final gifts = []; 

    for (var r in gifts) {
      await _gifts.record(r['id']!).put(db, r);
    }
  }

  Future<Map<dynamic,dynamic>> consultarYActualizarRegalo(String value) async {
    final db = await database;
    String idEmployee="";
    RecordSnapshot<int, Map<String, Object?>>? employee;

    if(value.length==6){
      idEmployee= value;
      employee = await _people.findFirst(db, finder: Finder(
        filter: Filter.and([
          Filter.equals('idEmployee', idEmployee),
          Filter.equals('isAdult', true)
        ])
      )
      );
    }
    else{
      idEmployee= value.toString().substring(1,7);
      employee = await _people.findFirst(db, finder: Finder(filter: Filter.equals('epc', value)));
    }
    
    final finderAdults = Finder(
      filter: Filter.and([
        Filter.equals('idEmployee', idEmployee),
        Filter.equals('isAdult', true)
      ]),
    );

    final finderChildren = Finder(
      filter: Filter.and([
        Filter.equals('idEmployee', idEmployee),
        Filter.equals('isAdult', false),
      ]),
    );

    final results = await Future.wait([
      _people.find(db, finder: finderAdults),
      _people.find(db,finder: finderChildren)
    ]);

    
    if(employee != null){
      //final existingParent = results[0];
      final existingChildren = results[1];
      
      //final timestampGift = existingParent[0]["timestampGift"] as int;


      //bool gift= employee.value["gift"] as bool;
      bool isAdult= employee.value["isAdult"] as bool;
      fs.Timestamp timestampGift = fs.Timestamp.now();

      var docs= await FirebaseService.peopleExists(idEmployee);
      final gift= docs[0]["gift"] as bool;

      if(docs.isNotEmpty){
        timestampGift= docs[0]["timestamp_gift"];
      }
      

      //child 
      if(!isAdult){
        // giftPermitted--;
        // await employee.ref.update(db, {"gift": true});
        // await _people.update(db,{'giftsPermitted': giftPermitted},finder: finderAdults);
        return {
          'message': 'ID $idEmployee no puede recibir regalo',
          'result':false
        };
      }

      //adults
      else{
        //gift received
        if(gift){
          return {
            'message': 'ID $idEmployee ya ha recibido regalos a las: ${timestampGift.toDate()}',
            'result':false
          };
        }
        else{
          //adult doesnt have children
          if(existingChildren.isEmpty){
            return {
              'message': 'El ID $idEmployee no tiene regalos por recibir',
              'result':false
            };  
          }
          return {
            'message': 'ID $idEmployee puede recibir  ${existingChildren.length} regalos',
            'result':true
          };
        }
        // if(giftPermitted>0){
        //   giftPermitted--;
          //final child = await _people.findFirst(db, finder: Finder(filter: Filter.equals('uuid', existingChildren[0]["uuid"])));
          // await child!.ref.update(db, {"gift": true});
          // await _people.update(db,{'giftsPermitted': giftPermitted},finder: finderAdults);

          //return "ID $idEmployee ha recibido el regalo de un niño, regalos restantes: $giftPermitted";
        // }
        // else{
        //   return "ID $idEmployee no puede recibir más regalos";
        // }
      }
    }
    else{
      return {
        'message': 'El ID $value es invalido o no existe',
        'result':false
      };
    }

    
    // if(!gift){
    //   await employee.ref.update(db, {"gift": "1"});
    //   return 'ID $idEmployee añadido con regalo';
    // }
    // else{
    //   return 'ID $idEmployee ya tiene regalo';
    // }
    
    
    
  }


  Future<void> saveGifts(String idEmployee) async {
    final db = await database;
    final finderAdults = Finder(
      filter: Filter.and([
        Filter.equals('idEmployee', idEmployee)
      ]),
    );

    await _people.update(db,{'gift': true, 'timestampGift': DateTime.now().millisecondsSinceEpoch},finder: finderAdults);
    
  }

  Future<void> refreshGifts() async {
    final db = await database;
    await _people.update(db,{'gift': false, 'timestampGift': 0});
  }

  Future<Map<String, dynamic>?> getDataEmployee(String key, String value) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals(key, value));
    final recordSnapshot = await _gifts.findFirst(db, finder: finder);
    return recordSnapshot?.value;
  }

  // Future<Map<String, dynamic>?> getRegaloById(String id) async {
  //   final db = await database;
  //   return await _gifts.record(id).get(db);  
  // }
  Future<Map<String, dynamic>?> getRegaloById(String id) async {
    final db = await database;
    return await _gifts.record(id).get(db);  
  }

  Future<int> getGiftCount() async {
    final db = await database;
    final records = await _gifts.find(db);
    return records.length;
  }

}
