import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';
import 'package:inditex_occupancy/db/db_sembast_helper.dart';
import 'package:inditex_occupancy/presentation/widgets/custom_appbar.dart';
import 'package:inditex_occupancy/presentation/widgets/side_menu.dart';
import 'package:sembast/sembast_io.dart';


class ZoneDetailScreen extends StatefulWidget {
  final String? peopleInside;
  final String? zone;
  final String? maxOccupancy;
  const ZoneDetailScreen({super.key, this.peopleInside, this.zone, this.maxOccupancy});

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  late DateTime startOfDay;
  late DateTime endOfDay;
  late DateTime startOfDay2;
  late DateTime endOfDay2;
  late DateTime startOfDay3;
  late DateTime endOfDay3;
  bool isLoadingData= false;
  List<Map<String, dynamic>> listPeopleFiltered=[];
  List<Map<String, dynamic>> employees=[];
  int adultsInside=0;
  int childrenInside=0;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();



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
    // startOfDay2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: -1));
    // endOfDay2 = startOfDay2.add(const Duration(days: 1));
    // startOfDay = DateTime(2025, 10, 21, 13, 19, 0);
    // endOfDay = DateTime(2025, 10, 22, 00, 00, 0);

    // startOfDay3 = DateTime(2025, 10, 22, 11, 00, 0);
    // endOfDay3 = DateTime(2025, 10, 23, 00, 00, 0);
    startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    endOfDay = startOfDay.add(const Duration(days: 1));
    getOccupancyData(startOfDay, endOfDay);  
  }

  Future<void> getOccupancyData(DateTime startOfDay, DateTime endOfDay) async {
    setState(() => isLoadingData = true);

    // List<RecordSnapshot<int, Map<String, dynamic>>> listEmployees;
    QuerySnapshot<Map<String, dynamic>> peopleDb;
    List<Map<String, dynamic>> result;
    

    if(widget.zone=="Gimnasio"){
      // listEmployees= await DbSembastHelper.instance.getEventsByDate(startOfDay, endOfDay, "gym"); 
      peopleDb = await FirebaseFirestore.instance
        .collection('inditex_people')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .where('storeId', isEqualTo: "1")
        .get();
        final docs = peopleDb.docs;

        result = docs.map((doc) => doc.data()).toList();     

        result = result.where((p) {
          final active = p['active'] ?? 0;
          return active == 1;
        }).toList();
    }
    else{
      //listEmployees= await DbSembastHelper.instance.getEventsByDate(startOfDay3, endOfDay3, "audit");
      peopleDb = await FirebaseFirestore.instance
        .collection('inditex_people')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .where('storeId', isEqualTo: "2")
        .get();
        final docs = peopleDb.docs;

        result = docs.map((doc) => doc.data()).toList();   
    }

    employees = result.map((record) {
        final data = record;
        return {
          'epc': data["epc"],
          'idEmployee': data['idEmployee'],
          'isAdult': data['isAdult'] == true ? 'Adulto' : 'Niño',
          'ticketNumber': data['ticketNumber'],
          'timestamp': data['timestamp'],
          'uuid': data['uuid'],
        };
      }).toList();

    List<Map<String, dynamic>> adultsInsideList = employees.where((r) => r['isAdult'] == 'Adulto').toList();
    List<Map<String, dynamic>> childrenInsideList = employees.where((r) => r['isAdult'] == 'Niño').toList();
              
    setState(() {
        listPeopleFiltered = [];
        adultsInside= adultsInsideList.length;
        childrenInside= childrenInsideList.length;
        // searchController.addListener(onSearchChanged);

        isLoadingData = false;
        
        
    });

  }

  //  void onSearchChanged() {
  //   final query = searchController.text.toUpperCase();
  //   setState(() {
  //    listPeopleFiltered = employees.where((item) {
  //     final queryLower = query.toUpperCase();
  //     return item["idEmployee"].toString().toUpperCase().contains(queryLower) ||
  //       item["epc"].toString().toUpperCase().contains(queryLower) ||
  //           item["isAdult"].toString().toUpperCase().contains(queryLower);
  //   }).toList();
  //   });
  // }
  void searchPeople(String value) {
    setState(() {
      if(value.length==6 || value.length == 24){  
        listPeopleFiltered = employees.where((item) {
          final queryUp = value.toUpperCase();
          if(value.length==6){
            focusNode.requestFocus();
            return item["idEmployee"].toString().toUpperCase()==queryUp;
          }
          else{
            searchController.text="";
            focusNode.requestFocus();
            return item["epc"].toString().toUpperCase()==queryUp;
          }
        }).toList();
      }
      else if(value.isEmpty){
        listPeopleFiltered.clear();
        focusNode.requestFocus();
        return;
      }
    });
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
          Padding(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 0), 
            child: SideMenu(principalActive: false, detailActive: true, giftActive: false, searchActive: false,
            sizeScreen: sizeScreen)),
          Padding(
          padding: EdgeInsets.fromLTRB(0,16,16,16),
          child:
          ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: sizeScreen.width>=500 ?sizeScreen.width-130 : sizeScreen.width-90,
          color: AppTheme.greyColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(widget.zone!, style: TextStyle(fontSize: sizeScreen.width>=500 ? 40: 25, fontWeight: FontWeight.w500)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: sizeScreen.width >= 500
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 250,
                                maxWidth: sizeScreen.width * 0.30,
                                minHeight: sizeScreen.height*0.75
                              ),
                              child: buildOccupancyCard("Gimnasio", sizeScreen, widget.maxOccupancy!),
                            ),
                            const SizedBox(width: 40),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 250,
                                maxWidth: sizeScreen.width * 0.30,
                                minHeight: 400,
                              ),
                              child: searchIdsCard(sizeScreen, int.parse(widget.peopleInside!), widget.maxOccupancy!),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildOccupancyCard("Gimnasio", sizeScreen, widget.maxOccupancy!),
                            const SizedBox(height: 50),
                            searchIdsCard(sizeScreen, int.parse(widget.peopleInside!), widget.maxOccupancy!),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
        ]
    )
  );
}

  Widget buildOccupancyCard(String title, Size sizeScreen, String maxOccupancy) {
  return Card(
    elevation: 10,
    shadowColor: AppTheme.secondaryColor,
    color: AppTheme.colorGeneral,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 6,
            child: SizedBox(
              width: double.infinity,
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ocupación Máxima',
                    style: TextStyle(fontSize: sizeScreen.width>=500 ? 25 : 17, fontWeight: FontWeight.w700),
                  ),
                  Text('${employees.length.toString()} / $maxOccupancy personas' ,
                    style: TextStyle(fontSize: sizeScreen.width>=500 ? 25 : 16, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 6,
            child: SizedBox(
              width: double.infinity,
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Adultos Dentro',
                    style: TextStyle(fontSize: sizeScreen.width>=500 ? 20 : 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    adultsInside.toString(),
                    style: TextStyle(fontSize: sizeScreen.width>=500 ? 60 : 40, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 6,
            child: SizedBox(
              width: double.infinity,
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Niños Dentro',
                    style: TextStyle(fontSize: sizeScreen.width>=500 ? 20 : 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    childrenInside.toString(),
                    style: TextStyle(fontSize: sizeScreen.width>=500 ? 60 : 40, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget searchIdsCard(Size sizeScreen, int peopleInside, String maxOccupancy) {
  return Card(
    elevation: 10,
    shadowColor: AppTheme.secondaryColor,
    color: AppTheme.colorGeneral,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card(
          //   elevation: 6,
          //   child: SizedBox(
          //     width: double.infinity,
          //     height: 140,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Text(
          //           'Lugares Disponibles',
          //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          //         ),
          //         Text(
          //           (int.parse(maxOccupancy) - (peopleInside)).toString(),
          //           style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w200),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Número Ticket', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: Scrollbar(
              thumbVisibility: true,
              interactive: true,
              controller: scrollController,
              child: ListView.builder(
                itemCount: listPeopleFiltered.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  final item = listPeopleFiltered[index];
                  return
                  InkWell(
                   
                  
                  onTap: () => {
                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          title: Text(
                                            'Detalles ID: ${item["idEmployee"]}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          contentPadding: const EdgeInsets.all(8), 
                                          content: SizedBox(
                                            width: 500, 
                                            height: 300,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                  color: AppTheme.primaryColor,
                                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                  child: const Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Step',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Place',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Timestamp',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 8),

                                                Expanded(
                                                  child: Scrollbar(
                                                    thumbVisibility: true, 
                                                    child: ListView.builder(
                                                      itemCount: 2, 
                                                      itemBuilder: (context, index) {
                                                        final step = index % 2 == 0 ? 'Enter' : 'Exit';
                                                        final place = index % 2 == 0 ? 'Gimnasio' : 'Auditorio';
                                                        final timestamp = '12/10/2025 10:${30 + index}';

                                                        return Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 10,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: index.isEven
                                                                ? Colors.grey[100]
                                                                : Colors.white,
                                                            border: Border(
                                                              bottom: BorderSide(color: Colors.grey.shade300),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(flex: 1, child: Text(step)),
                                                              Expanded(flex: 1, child: Text(place)),
                                                              Expanded(flex: 1, child: Text(timestamp)),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'Cerrar',
                                                style: TextStyle(color: AppTheme.primaryColor),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                  
                  
                  },
                  hoverColor: Colors.grey[200],
                  child:  Padding(
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
                            item["isAdult"].toString(),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item["ticketNumber"].toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                }
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}








// class SimpleLabel extends StatelessWidget {
//   final String label;

//   const SimpleLabel({super.key, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       label,
//       style: const TextStyle(fontSize: 14, color: Colors.white),
//     );
//   }
// }

// class RectangularInfo extends StatelessWidget {
//   final String label;
//   final String value;
//   final double labelFontSize;
//   final double valueFontSize;
//   final double width;

//   const RectangularInfo({
//     super.key,
//     required this.label,
//     required this.value,
//     this.labelFontSize = 10,
//     this.valueFontSize = 15,
//     this.width = 180,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: 75,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white24,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: labelFontSize, color: Colors.white),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: valueFontSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LargeRectInfo extends StatelessWidget {
//   final String label;
//   final String value;
//   final double labelFontSize;
//   final double valueFontSize;
//   final double width;

//   const LargeRectInfo({
//     super.key,
//     required this.label,
//     required this.value,
//     this.labelFontSize = 12,
//     this.valueFontSize = 56,
//     this.width = 200,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: 140,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white24,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: labelFontSize, color: Colors.white),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: valueFontSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }