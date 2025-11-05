import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inditex_occupancy/config/router/router.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';
import 'package:inditex_occupancy/db/db_sembast_helper.dart';
import 'package:inditex_occupancy/presentation/widgets/custom_appbar.dart';
import 'package:inditex_occupancy/presentation/widgets/side_menu.dart';
import 'package:sembast/sembast_io.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoadingData= false;
  List<Map<String, dynamic>> listPeopleFiltered=[];
  List<Map<String, dynamic>> people=[];
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late DateTime startOfDay;
  late DateTime endOfDay;
  late DateTime startOfDay2;
  late DateTime endOfDay2;
  late final ScrollController horizontal;

  late final Stream<QuerySnapshot> gymStream;



  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    horizontal = ScrollController();
  
    startOfDay2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: -1));
    endOfDay2 = startOfDay2.add(const Duration(days: 1));
    // startOfDay = DateTime(2025, 10, 21, 13, 19, 0);
    // endOfDay = DateTime(2025, 10, 22, 00, 00, 0);
    startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    endOfDay = startOfDay.add(const Duration(days: 1));

    getPeopleData(startOfDay, endOfDay);  
  }

  Future<void> getPeopleData(DateTime startOfDay, DateTime endOfDay) async {
    setState(() => isLoadingData = true);

    List<RecordSnapshot<int, Map<String, dynamic>>> listPeople;


    //listPeople= await DbSembastHelper.instance.getEventsByDate(startOfDay, endOfDay, "people");
    
    // people = listPeople.map((record) {
    //     final data = record.value;
    //     return {
    //       'epc': data["epc"],
    //       'idEmployee': data['idEmployee'],
    //       'isAdult': data['isAdult'] == true ? 'Adult' : 'Child',
    //       'ticketNumber': data['ticketNumber'],
    //       'timestamp': data['timestamp'],
    //       'uuid': data['uuid'],
    //       'zone': data["zone"],
    //       "gift": data["gift"],
    //       "giftsPermitted": data["giftsPermitted"]
    //     };
    //   }).toList();

    setState(() {
        listPeopleFiltered = [];
        // searchController.addListener(onSearchChanged);
        isLoadingData = false;
    });
  }

// void onSearchChanged() {
//   final query = searchController.text.toUpperCase();
//   setState(() {
//     listPeopleFiltered = people.where((item) {
//       final queryLower = query.toUpperCase();
//       return item["idEmployee"].toString().toUpperCase().contains(queryLower) ||
//       item["isAdult"].toString().toUpperCase().contains(queryLower) ||
//       item["epc"].toString().toUpperCase().contains(queryLower) ||
//       item["zone"].toString().toUpperCase().contains(queryLower);
//     }).toList();
//   });
// }
void searchPeople(String value) async{
  if(value.length==6 || value.length == 24){  
        QuerySnapshot<Map<String, dynamic>> peopleDb;
        String idEmployee="";
        if(value.length==6){
          idEmployee= value;
          peopleDb = await FirebaseFirestore.instance
          .collection('inditex_people')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .where('idEmployee', isEqualTo: idEmployee)
          .get();
        }
        else{
          peopleDb = await FirebaseFirestore.instance
          .collection('inditex_people')
          // .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          // .where('timestamp', isLessThan: endOfDay)
          .where('epc', isEqualTo: value)
          .get();
        }

        
        final docs = peopleDb.docs;
        docs.sort((a, b) {
          final t1 = a["timestamp"] ?? 0;
          final t2 = b["timestamp"] ?? 0;
          return t1.compareTo(t2);
        });

        final result = docs.map((doc) => doc.data()).toList();
    setState(() {
        listPeopleFiltered= result;

        // listPeopleFiltered = people.where((item) {
        //   final queryUp = value.toUpperCase();
        //   if(value.length==6){
        //     focusNode.requestFocus();
        //     return item["idEmployee"].toString().toUpperCase()==queryUp;
        //   }
        //   else{
        //     searchController.text="";
        //     focusNode.requestFocus();
        //     return item["epc"].toString().toUpperCase()==queryUp;
        //   }
        // }).toList();
      
      
    });
  }
  else if(value.isEmpty){
        listPeopleFiltered.clear();
        focusNode.requestFocus();
        return;
      }
}


  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    return Scaffold(
    backgroundColor: Colors.white,
    appBar: CustomAppbar(sizeScreen: sizeScreen),
    body: isLoadingData ? Center(child: CircularProgressIndicator()) : 
    Row(
        children:[ 
          SideMenu(principalActive: false, detailActive: false, giftActive: false, searchActive: true,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: 
                    SizedBox(
                      width: sizeScreen.width>=500 ? sizeScreen.width-200 : sizeScreen.width,
                      height: sizeScreen.width>=500 ? sizeScreen.height*0.8 : sizeScreen.height*0.85 ,
                      child: Card(
                        elevation: 10,
                        shadowColor: AppTheme.secondaryColor,
                        color: AppTheme.colorGeneral,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: 
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: 
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Buscar Personas',
                                        style: TextStyle(
                                          fontSize: sizeScreen.width>=500 ? 27 : 18,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: sizeScreen.width>=500 ? 40 : 20),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: sizeScreen.width>=500 ? 250 : 180,
                                        child: TextField(
                                          controller: searchController,
                                          focusNode: focusNode,
                                          onSubmitted: (value) {
                                            searchPeople(value);
                                          },
                                          style: TextStyle(fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Buscar...',
                                            prefixIcon: const Icon(Icons.search),
                                            filled: true,
                                            fillColor: AppTheme.greyColor,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  sizeScreen.width>=500 ?
                                  Column(
                                    children: [
                                      SizedBox(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: 
                                          Container(
                                            color: AppTheme.primaryColor,
                                            padding: EdgeInsets.all(8),
                                            child: 
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                                                  Expanded(flex: 1, child: Text('Número Ticket', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                                                  Expanded(flex: 1, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                                                  Expanded(flex: 2, child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                                                  Expanded(flex: 1, child: Text('Zona', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                                                  Expanded(flex: 1, child: Text('Regalo', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                                                ],
                                              ),
                                            )
                                      ),
                                      ),      
                                    SizedBox(
                                      height: sizeScreen.height*0.5,
                                      child: Scrollbar(
                                        thumbVisibility: true,
                                        interactive: true,
                                        controller: scrollController,
                                        child: ListView.builder(
                                          itemCount: listPeopleFiltered.length,
                                          controller: scrollController,
                                          itemBuilder: (context, index) {
                                            
                                            final item = listPeopleFiltered[index];
                                            final timestamp= item["timestamp"] as Timestamp;
                                            final finalDate= timestamp.toDate();
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      item["idEmployee"].toString()
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      item["ticketNumber"].toString(),
                                                      // item["giftsPermitted"].toString(),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      item["isAdult"] == true ? 'Adulto' : 'Niño',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      finalDate.toString(),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      //item["zone"].toString()== "gym" ? 'Gimnasio' : "Auditorio",
                                                      '${item["step"].toString()} ${item["actualZone"]}',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      item["isAdult"]==true? "N/A" :
                                                      item["gift"]== true ? 'Ok' : "No",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        )
                                      )
                                    )
                                    ]
                                    )
                                    :
                                    SizedBox(
                                      height: sizeScreen.height * 0.65,
                                      child: ListView.builder(
                                        itemCount: listPeopleFiltered.length,
                                        itemBuilder: (context, index) {
                                          final item = listPeopleFiltered[index];
                                          final timestamp= item["timestamp"] as Timestamp;
                                            final finalDate= timestamp.toDate();
                                          return SizedBox(
                                            height: 80,
                                            child: Card(
                                              color: AppTheme.extraColor,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(10),
                                                          topLeft: Radius.circular(10)
                                                        ),
                                                        color: AppTheme.buttonsColor,
                                                      ),
                                                      padding: EdgeInsetsGeometry.fromLTRB(5, 0, 5, 0),
                                                      child: Row(children: [
                                                        Text(
                                                          'Id:', 
                                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)
                                                        ),
                                                        Text(
                                                          item["idEmployee"], 
                                                          style: TextStyle(color: Colors.white, fontSize: 12,)
                                                        ),

                                                        Expanded(
                                                          child: Text(
                                                            item["isAdult"] == true ? 'Adulto' : 'Niño', 
                                                            textAlign: TextAlign.right,
                                                            style: TextStyle(color: Colors.white, fontSize: 12,)
                                                          ),
                                                        ),
                                                      ],),
                                                    )
                                                  ),
                                                  Expanded(
                                                    flex: 6,
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(5,0,5,0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(finalDate.toString(),
                                                            style: TextStyle(fontSize: 13),
                                                            textAlign: TextAlign.start,
                                                            ),
                                                            Text('${item["step"].toString()} ${item["actualZone"]}',
                                                            style: TextStyle(fontSize: 13),
                                                            textAlign: TextAlign.start,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    
                                                  )
                                                ],
                                              )
                                            ),
                                          );
                                        },
                                      ),
                                    )

                                    // SingleChildScrollView(
                                    //   child: 
                                    //     Column(
                                    //       children: [
                                    //         ListView.builder( 
                                    //           itemCount: listPeopleFiltered.length,
                                    //           itemBuilder:(context, index) {
                                    //           final menuItem= listPeopleFiltered[index];
                                    //           return Text('data');
                                    //         })
                                    //       ]
                                    //     )
                                    // )

          ]
          ),
          ),
          ),
          ),
      ),
              ]
    )
        
          )
        )
          )
        
    )
        ]
    )   
    );
         
  }
}