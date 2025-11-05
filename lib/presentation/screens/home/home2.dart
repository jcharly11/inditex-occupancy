import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inditex_occupancy/config/router/router.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';
import 'package:inditex_occupancy/presentation/widgets/custom_appbar.dart';
import 'package:inditex_occupancy/presentation/widgets/side_menu.dart';
import 'package:intl/intl.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2dState();
}

class _Home2dState extends State<Home2> {
  late final DateTime startOfDay;
  late final DateTime endOfDay;

  late final Stream<QuerySnapshot> gymStream;
  late final Stream<QuerySnapshot> auditStream;
    int maxOccupancyGym= 30;
  int maxOccupancyAudit= 20;
  double gymPercent=0;
  double auditPercent=0;
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();

    // Cálculo del rango de hoy
    startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    endOfDay = startOfDay.add(const Duration(days: 1));

    // Consulta para storeId == "1"
    gymStream = FirebaseFirestore.instance
        .collection('inditex_people')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .where('status', isEqualTo: 1)
        .where('storeId', isEqualTo: '1')
        .snapshots();

    // Consulta para storeId == "2"
    auditStream = FirebaseFirestore.instance
        .collection('inditex_people')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .where('status', isEqualTo: 1)
        .where('storeId', isEqualTo: '2')
        .snapshots();

  }

@override
Widget build(BuildContext context) {
  final sizeScreen = MediaQuery.of(context).size;


  return Scaffold(
    appBar: CustomAppbar(sizeScreen: sizeScreen),
    body: 
    // isLoadingData
    //     ? LoaderScreen()
        // : 
        Row(
            children: [
              SideMenu(
                principalActive: true,
                detailActive: false,
                giftActive: false,
                searchActive: false,
                sizeScreen: sizeScreen,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: sizeScreen.width >= 500
                        ? sizeScreen.width - 130
                        : sizeScreen.width - 90,
                    height: double.infinity,
                    color: AppTheme.greyColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: SizedBox(
                        height: double.infinity,
                        child: sizeScreen.width >= 500
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 40,
                                children: [
                                  // 🏋️‍♂️ GIMNASIO
                                  StreamBuilder<QuerySnapshot>(
                                    stream: gymStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        print(
                                            'Error Gimnasio: ${snapshot.error}');
                                        return const Text(
                                            'Error al cargar datos del Gimnasio');
                                      }
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      final docs = snapshot.data!.docs;
                                      final total = docs.length;

                                      // Calcular porcentaje dinámico
                                      final double percent = total /
                                          (maxOccupancyGym == 0
                                              ? 1
                                              : maxOccupancyGym) *
                                          100;

                                      final color = percent < 50
                                          ? Colors.green
                                          : percent < 80
                                              ? Colors.orange
                                              : Colors.red;

                                      return buildOccupancyCard(
                                        "Gimnasio",
                                        total,
                                        percent,
                                        maxOccupancyGym,
                                        color,
                                        context,
                                        sizeScreen,
                                        false,
                                        endOfDay,
                                        formatter,
                                      );
                                    },
                                  ),

                                  // 🏛️ AUDITORIO
                                  StreamBuilder<QuerySnapshot>(
                                    stream: auditStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        print(
                                            'Error Auditorio: ${snapshot.error}');
                                        return const Text(
                                            'Error al cargar datos del Auditorio');
                                      }
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      final docs = snapshot.data!.docs;
                                      final total = docs.length;

                                      final double percent = total /
                                          (maxOccupancyAudit == 0
                                              ? 1
                                              : maxOccupancyAudit) *
                                          100;

                                      final color = percent < 50
                                          ? Colors.green
                                          : percent < 80
                                              ? Colors.orange
                                              : Colors.red;

                                      return buildOccupancyCard(
                                        "Auditorio",
                                        total,
                                        percent,
                                        maxOccupancyAudit,
                                        color,
                                        context,
                                        sizeScreen,
                                        false,
                                        endOfDay,
                                        formatter,
                                      );
                                    },
                                  ),
                                ],
                              )
                            :
                            // 🔹 Versión para pantallas pequeñas
                            SingleChildScrollView(
                                child: Column(
                                  spacing: 50,
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                      stream: gymStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Error al cargar Gimnasio');
                                        }
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }

                                        final docs = snapshot.data!.docs;
                                        final total = docs.length;
                                        final percent = total /
                                            (maxOccupancyGym == 0
                                                ? 1
                                                : maxOccupancyGym) *
                                            100;
                                        final color = percent < 50
                                            ? Colors.green
                                            : percent < 80
                                                ? Colors.orange
                                                : Colors.red;

                                        return buildOccupancyCard(
                                          "Gimnasio",
                                          total,
                                          percent,
                                          maxOccupancyGym,
                                          color,
                                          context,
                                          sizeScreen,
                                          false,
                                          endOfDay,
                                          formatter,
                                        );
                                      },
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: auditStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Error al cargar Auditorio');
                                        }
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }

                                        final docs = snapshot.data!.docs;
                                        final total = docs.length;
                                        final percent = total /
                                            (maxOccupancyAudit == 0
                                                ? 1
                                                : maxOccupancyAudit) *
                                            100;
                                        final color = percent < 50
                                            ? Colors.green
                                            : percent < 80
                                                ? Colors.orange
                                                : Colors.red;

                                        return buildOccupancyCard(
                                          "Auditorio",
                                          total,
                                          percent,
                                          maxOccupancyAudit,
                                          color,
                                          context,
                                          sizeScreen,
                                          false,
                                          endOfDay,
                                          formatter,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}



Widget buildOccupancyCard(String title, int peopleInside, double percent, int people, Color color, BuildContext context, 
  Size sizeScreen, bool isLoadingData, DateTime startDate, DateFormat formatter){
    return Card(
      elevation: 10,
      shadowColor: AppTheme.secondaryColor,
      color: AppTheme.colorGeneral,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: 
      //isLoadingData ? Center(child: CircularProgressIndicator(),): 
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
                  //isLoadingData ? CircularProgressIndicator() :
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
}