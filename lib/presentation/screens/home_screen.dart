import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inditex_occupancy/data/models/events_firebase_model.dart';
import 'package:inditex_occupancy/db/db_sqlite_helper.dart';


class HomeScreen extends StatefulWidget {
  static const name= 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime startOfDay;
  late DateTime endOfDay;
  String accountId= "39100";
  String storeId= "7329";
  bool isLoadingData= false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> eventsList = [];
  StreamSubscription? eventsSub;
  final db = DbSqliteHelper.instance;
  
  @override
  void initState(){
    super.initState();
    startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: -1));
    endOfDay = startOfDay.add(const Duration(days: 1));

    getOccupancyData(startOfDay, endOfDay);  
  }

  
  Future<void> getOccupancyData(DateTime startOfDay, DateTime endOfDay) async {
    setState(() => isLoadingData = true);

    eventsSub = FirebaseFirestore.instance
        .collection('events')
        .doc(accountId)
        .collection(storeId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) async {
          final docsFiltered = (snapshot.docs
          .where((e) => e["eventId"] == "rfid_exit")
          .toList()
          ..sort((a, b) => b["timestamp"].compareTo(a["timestamp"]))).toList();
        
        var a= 1;
        // for (final doc in docsFiltered) {
        //   final model = EventsFirebaseModel.fromMap(doc.data());
        //   await db.saveEvents(
        //     {
        //       "uuid": model.uuid,
        //       "accountNumber": accountId,
        //       "storeId": storeId,
        //       "eventId": model.eventId,
        //       "silent": model.silent ? 1 : 0,
        //       "groupId": model.groupId,
        //       "timestamp": model.timestamp.toDate().millisecondsSinceEpoch,
        //       "deviceId": model.deviceId,
        //       "deviceModel": model.deviceModel,
        //       "technology": model.technology,
        //       "doorName": model.doorName
        //     },
        //     model.enrich,
        //     model.mqttdata
        //   );
        // }
        // final itemsDb = await db.getEventsByDate(startOfDay, endOfDay, "0");
        // final enrichedEvents = await Future.wait(itemsDb.map((doc) async {
        //   final enrich = await db.getEnrichData(doc["idEvent"], doc["uuid"]);
        //   final mqtt = await db.getMqttData(doc["idEvent"]);
        //   return {...doc, "enrich": enrich, "mqttdata": mqtt};
        // }));
        
    setState(() {
        eventsList = docsFiltered;
        isLoadingData = false;
      });
    });


  }

  @override
  void dispose() {
    eventsSub?.cancel();
    super.dispose();
  }


  


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: isLoadingData ? Center(
        child: CircularProgressIndicator()
      ) : 
      
      Center(child: 
        Text(eventsList.length.toString())
      ),
    );
  }
}