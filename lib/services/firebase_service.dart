import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
class FirebaseService {

  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  static Future<void> insertPeopleGift(String idEmployee) async {
    await firestore.collection('inditex_people').add({
      'id_employee': idEmployee,
      'gift': false,
      'timestamp_gift': null
    });
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> peopleExists(String idEmployee)async {
      QuerySnapshot<Map<String, dynamic>>? snapshot;
      
      snapshot = await FirebaseFirestore.instance
      .collection('inditex_people')
      .where('idEmployee', isEqualTo: idEmployee)
      .get();

      
      if(snapshot.size>0){
        
        return snapshot.docs.toList();
      }
      else {
        return [];
      }
  }

  static Future<void> updatePeopleGift(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in docs) {
      final docRef = FirebaseFirestore.instance.collection('inditex_people').doc(doc.id);
      batch.update(docRef, {'gift': true, 'timestampGift': Timestamp.fromDate(DateTime.now())});
    }

    await batch.commit();
  
  //   await FirebaseFirestore.instance
  //     .collection('inditex_people')
  //     .doc(docId)
  //     .update({
  //       'gift': true,
  //       'timestamp_gift': Timestamp.fromDate(DateTime.now())
  //     });
  // }

  //  Future<Map<dynamic,dynamic>> getStatusGift(String idEmployee) async {
  //   await FirebaseFirestore.instance
  //     .collection('inditex_people')
  //     .doc(docId)
  //     .update({
  //       'gift': true,
  //       'timestamp_gift': Timestamp.fromDate(DateTime.now())
  //     });
  // }
  }

  Future<Map<dynamic,dynamic>> getStatusGift(String value) async {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    String idEmployee="";
    // QuerySnapshot<Map<String, dynamic>>? snapshot;
    Future<QuerySnapshot<Map<String, dynamic>>> snapshot;
    Future<QuerySnapshot<Map<String, dynamic>>> snapshotEPC;
    QuerySnapshot<Map<String, dynamic>> docsPeople;
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> adult;

    if(value.length==6) {
      idEmployee= value;
      snapshot = FirebaseFirestore.instance
      .collection('inditex_people')
      .where('idEmployee', isEqualTo: idEmployee)
      .get();    
      docsPeople = await snapshot;
      adult= docsPeople.docs.where((e) => e["isAdult"] == true);
    }
    else{
      idEmployee= value.toString().substring(1,7);
      snapshotEPC = FirebaseFirestore.instance
      .collection('inditex_people')
      .where('epc', isEqualTo: value)
      .get();  
      docsPeople = await snapshotEPC; 
      if(docsPeople.docs[0]["isAdult"]==false){
        adult= docsPeople.docs;
      }
      else{
        adult= docsPeople.docs.where((e) => e["isAdult"] == true);
      } 
    }
    
    
    if(docsPeople.docs.isNotEmpty){
      //final existingChildren = results[1];
      
      DateTime timestampGift= DateTime.now();
      bool isAdult= adult.first["isAdult"] as bool;
      bool gift= adult.first["gift"] as bool;
      final timestampG= adult.first["timestampGift"];
      if(timestampG!=null){
        final time= timestampG as Timestamp;
        timestampGift= time.toDate();
      }

      // if(docs.isNotEmpty){
      //   timestampGift= docs[0]["timestamp_gift"];
      // }
      
      if(gift){
        return {
            'message': 'ID $idEmployee ya ha recibido regalos a las: ${formatter.format(timestampGift)}',
            'result':false
          };
      }
      else{

      
        //child 
        if(!isAdult){
          return {
            'message': 'El EPC $value pertenece a un niño, solo adultos pueden recibir regalos',
            'result':false
          };
        }

        //adults
        else{
          //gift received
          if(gift){
            return {
              'message': 'ID $idEmployee ya ha recibido regalos a las: ${timestampGift.toString()}',
              'result':false
            };
          }
          else{
            //adult doesnt have children
            final snapshotChild = FirebaseFirestore.instance
            .collection('inditex_people')
            .where('idEmployee', isEqualTo: idEmployee)
            .get();
            final docsChildren= await snapshotChild;
            final existsChildren= docsChildren.docs.where((e) => e["isAdult"] == false && e["gift"] == false);


            if(existsChildren.isEmpty){
              return {
                'message': 'El ID $idEmployee no tiene regalos por recibir',
                'result':false
              };  
            }
            return {
              'message': 'ID $idEmployee puede recibir  ${existsChildren.length} regalos',
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

  Future<void> restoreGifts() async {
  final collectionRef = FirebaseFirestore.instance.collection('inditex_people');

  final querySnapshot = await collectionRef.get();
  final docs = querySnapshot.docs;

  const batchSize = 500;
  for (var i = 0; i < docs.length; i += batchSize) {
    final batch = FirebaseFirestore.instance.batch();

    final chunk = docs.skip(i).take(batchSize);
    for (var doc in chunk) {
      batch.update(doc.reference, {
        'gift': false,
        'timestampGift': null
      });
    }
    await batch.commit();
  }
}


  
}