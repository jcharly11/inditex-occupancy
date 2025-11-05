import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:inditex_occupancy/config/router/router.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';
import 'package:inditex_occupancy/db/db_sembast_helper.dart';
import 'package:inditex_occupancy/presentation/widgets/custom_appbar.dart';
import 'package:inditex_occupancy/presentation/widgets/loader_screen.dart';
import 'package:inditex_occupancy/presentation/widgets/side_menu.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast_io.dart';

class HomeScreen extends StatefulWidget {
  static const name= 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime startOfDay;
  late DateTime endOfDay;
  late DateTime startOfDay2;
  late DateTime endOfDay2;
  late DateTime startOfDay3;
  late DateTime endOfDay3;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String accountIdGym= "999";
  String storeIdGym= "1";
  String accountIdAudit= "999";
  String storeIdAudit= "1";
  bool isLoadingData= false;
  int maxOccupancyGym= 30;
  int maxOccupancyAudit= 20;
  double gymPercent=0;
  double auditPercent=0;

  // List<QueryDocumentSnapshot<Map<String, dynamic>>> eventsList = [];
  // List<Map<String, dynamic>> eventsList=[];
  List<RecordSnapshot<int, Map<String, dynamic>>> eventsListGym=[];
  List<RecordSnapshot<int, Map<String, dynamic>>> eventsListAudit=[];
  StreamSubscription? eventsSubGimnasio;
  StreamSubscription? eventsSubAudit;
  
  @override
  void initState(){
    super.initState();
    startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: -1));
    endOfDay = startOfDay.add(const Duration(days: 1));

    startOfDay2 = DateTime(2025, 10, 21, 13, 19, 0);
    endOfDay2 = DateTime(2025, 10, 22, 00, 00, 0);

    startOfDay3 = DateTime(2025, 10, 22, 11, 01, 0);
    endOfDay3 = DateTime(2025, 10, 23, 00, 00, 0);

    getOccupancyData(startOfDay, endOfDay);  
  }

  Future<void> getOccupancyData(DateTime startOfDay, DateTime endOfDay) async {
  setState(() => isLoadingData = true);

  await eventsSubGimnasio?.cancel();
  await eventsSubAudit?.cancel();

  int listenersReady = 0; 

  
  eventsSubGimnasio = FirebaseFirestore.instance
      .collection('events')
      .doc(accountIdGym)
      .collection(storeIdGym)
      .where('timestamp', isGreaterThanOrEqualTo: startOfDay2)
      .where('timestamp', isLessThan: endOfDay2)
      //.where('eventId', isEqualTo: 'rfid_exit')
      .snapshots()
      .listen((snapshot) async {
    final docsFiltered = snapshot.docs
        .map((e) => e.data())
        .where((data) => data["eventId"] == "rfid_exit" && data["timestamp"] != null)
        .toList();

    docsFiltered.sort((a, b) {
      final t1 = a["timestamp"] ?? 0;
      final t2 = b["timestamp"] ?? 0;
      return t2.compareTo(t1);
    });

    
    for (final doc in docsFiltered) {
      await DbSembastHelper.instance.saveEvent(
        {
          "uuid": doc["uuid"],
          "timestamp": (doc["timestamp"] as Timestamp).millisecondsSinceEpoch,
          "doorName": doc["doorName"]
        },
        doc["epc"],
        "gym",
      );
    }


    final itemsDbGym = await DbSembastHelper.instance.getEventsByDate(startOfDay2, endOfDay2, "gym");

    if (mounted) {
      setState(() {
        eventsListGym = itemsDbGym;
        gymPercent = (eventsListGym.length * 100) / maxOccupancyGym;
      });

      if (listenersReady < 2) {
        listenersReady++;
        if (listenersReady == 2 && mounted) {
          setState(() => isLoadingData = false);
        }
      }
    }
  });

 
  eventsSubAudit = FirebaseFirestore.instance
      .collection('events')
      .doc(accountIdAudit)
      .collection(storeIdAudit)
      .where('timestamp', isGreaterThanOrEqualTo: startOfDay3)
      .where('timestamp', isLessThan: endOfDay3)
      // .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
      // .where('timestamp', isLessThan: endOfDay)
      .snapshots()
      .listen((snapshot) async {
    final docsFiltered = snapshot.docs
        .map((e) => e.data())
        .where((data) => data["eventId"] == "rfid_exit" && data["timestamp"] != null)
        .toList();

    docsFiltered.sort((a, b) {
      final t1 = a["timestamp"] ?? 0;
      final t2 = b["timestamp"] ?? 0;
      return t2.compareTo(t1);
    });

    for (final doc in docsFiltered) {
      await DbSembastHelper.instance.saveEvent(
        {
          "uuid": doc["uuid"],
          "timestamp": (doc["timestamp"] as Timestamp).millisecondsSinceEpoch,
          "doorName": doc["doorName"]
        },
        doc["epc"],
        "audit",
      );
    }

    final itemsDbAudit =await DbSembastHelper.instance.getEventsByDate(startOfDay3, endOfDay3, "audit");
    

    if (mounted) {
      setState(() {
        eventsListAudit = itemsDbAudit;
        auditPercent = (eventsListAudit.length * 100) / maxOccupancyAudit;
      });

      if (listenersReady < 2) {
        listenersReady++;
        if (listenersReady == 2 && mounted) {
          setState(() => isLoadingData = false);
        }
      }
    }
  });
}


  
  


  @override
  Widget build(BuildContext context) {
    
    final sizeScreen = MediaQuery. of(context).size;
    
    return Scaffold(
      appBar: CustomAppbar(sizeScreen: sizeScreen),
      body: 
      isLoadingData ? 
      LoaderScreen()
      :
      Row(
        children:[ 
          SideMenu(principalActive: true, detailActive: false, giftActive: false, searchActive: false,
          sizeScreen: sizeScreen),
          Padding(
          padding: EdgeInsets.fromLTRB(0,16,16,16),
          child:
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: sizeScreen.width>=500 ?sizeScreen.width-130 : sizeScreen.width-90,
              height: double.infinity,
              color: AppTheme.greyColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 20),
                    child: SizedBox(
                        height: double.infinity,
                        child: 
                          sizeScreen.width>=500 ?
                          Row(
                          spacing: 40,
                          children: [
                            
                            buildOccupancyCard("Gimnasio", eventsListGym.length, gymPercent, maxOccupancyGym, 
                            gymPercent<50 ? Colors.green : 
                            gymPercent>=50 && gymPercent<80 ? Colors.orange:
                            Colors.red, context, sizeScreen, isLoadingData, endOfDay, formatter),
                            buildOccupancyCard("Auditorio", eventsListAudit.length, auditPercent, maxOccupancyAudit,
                            auditPercent<50 ? Colors.green : 
                            auditPercent>=50 && auditPercent<80 ? Colors.orange:
                            Colors.red, context, sizeScreen, isLoadingData, endOfDay, formatter),
                          ],
                        ):
        
                        SingleChildScrollView(
                          child: Column(
                            spacing: 50,
                            children: [
                              buildOccupancyCard("Gimnasio", eventsListGym.length, gymPercent, maxOccupancyGym, 
                              gymPercent<50 ? Colors.green : 
                              gymPercent>50 && gymPercent<80 ? Colors.orange:
                              Colors.red, context, sizeScreen, isLoadingData, endOfDay, formatter),
                              
                              buildOccupancyCard("Auditorio",eventsListAudit.length, auditPercent, maxOccupancyAudit, 
                              auditPercent<50 ? Colors.green : 
                              auditPercent>50 && auditPercent<80 ? Colors.orange:
                              Colors.red, context, sizeScreen, isLoadingData, endOfDay, formatter),
                            ],
                          ),
                        )
        
                      ),
                    
                  )
                ],
              )
              ),
          )
        )
        ]
      )
    );
 
  }
  }




  Widget buildOccupancyCard(String title, int peopleInside, double percent, int people, Color color, BuildContext context, 
  Size sizeScreen, bool isLoadingData, DateTime startDate, DateFormat formatter){
    return Card(
      elevation: 10,
      shadowColor: AppTheme.secondaryColor,
      color: AppTheme.colorGeneral,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: isLoadingData ? Center(child: CircularProgressIndicator(),): 
      InkWell(
        onTap: (){
          appRouter.go('/details/$peopleInside/$title/$people');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor
                    ),
                  ),
                ],
              ),
              
              sizeScreen.width >=500 ? 
              Expanded(
                child: SizedBox(
                  width: sizeScreen.width>=500 ? sizeScreen.width * 0.30 : sizeScreen.width ,
                  child: 
                  isLoadingData ? CircularProgressIndicator() :
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          centerSpaceRadius: 
                          sizeScreen.width>=900 ? 120 : 
                          sizeScreen.width>=750 && sizeScreen.width<=900 ? 90:
                          sizeScreen.width>=500 && sizeScreen.width<=750 ? 60:
                          sizeScreen.width<=500 ? 30: 20,
                          
                          sections: [
                            PieChartSectionData(
                              value: percent,
                              color: color,
                              radius: 25,
                              showTitle: false 
                            ),
                            PieChartSectionData(
                              value: 100 - percent,
                              color: Colors.grey.shade300,
                              radius: 20,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${percent.toInt()}%',
                            style: TextStyle(
                              fontSize:
                              sizeScreen.width>=900 ? 60 : 
                              sizeScreen.width>=750 && sizeScreen.width<=900 ? 50:
                              sizeScreen.width>=550 && sizeScreen.width<=750 ? 40: 30,
                              fontWeight: FontWeight.w600
                              ),
                          ),
                          Text(
                            '$peopleInside / $people personas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ):

              //movil view
              SizedBox(
                width: sizeScreen.width * 0.50,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 70,
                          
                        sections: [
                          PieChartSectionData(
                            value: percent,
                            color: color,
                            radius: 25,
                            showTitle: false 
                          ),
                          PieChartSectionData(
                            value: 100 - percent,
                            color: Colors.grey.shade300,
                            radius: 20,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Text('${percent.toInt()}%',
                          style: TextStyle(
                            fontSize:
                            sizeScreen.width>=900 ? 60 : 
                            sizeScreen.width>=750 && sizeScreen.width<=900 ? 50:
                            sizeScreen.width>=550 && sizeScreen.width<=750 ? 40: 30,
                            fontWeight: FontWeight.w600
                            ),
                        ),
                        Text(
                          '$people personas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text('Personas dentro: ${peopleInside.toString()}', 
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600
              ),)
              ,
              const SizedBox(height: 8),
              Text(
                formatter.format(startDate),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
