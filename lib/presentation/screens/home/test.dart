import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inditex_occupancy/presentation/widgets/custom_appbar.dart';
import 'package:rxdart/rxdart.dart';

class Test extends StatefulWidget {
  // final String eventId;
  // final DateTime today;
  // final DateTime yesterday;

  const Test({
    super.key,
    // required this.eventId,
    // required this.today,
    // required this.yesterday,
  });

  @override
  State<Test> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    final startOfToday = DateTime(2025, 10, 21, 13, 19, 0);
    final endOfToday = DateTime(2025, 10, 22, 00, 00, 0);

    final startOfYesterday = DateTime(2025, 10, 22, 11, 01, 0);
    final endOfYesterday = DateTime(2025, 10, 23, 00, 00, 0);

    // 🔸 Zona 1: eventos de hoy
    final zone1Stream = FirebaseFirestore.instance
        .collection('events')
        .doc('999')
        .collection('1')
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .where('timestamp', isLessThan: endOfToday)
        .where('eventId', isEqualTo: 'rfid_exit')
        .snapshots();
    

    // 🔸 Zona 2: eventos de ayer (pero misma colección real)
    final zone2Stream = FirebaseFirestore.instance
        .collection('events')
        .doc('999')
        .collection('1')
        .where('timestamp', isGreaterThanOrEqualTo: startOfYesterday)
        .where('timestamp', isLessThan: endOfYesterday)
        .where('eventId', isEqualTo: 'rfid_exit')
        .snapshots();
    
    return StreamBuilder<List<QuerySnapshot>>(
      stream: CombineLatestStream.list([zone1Stream, zone2Stream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final zone1Docs = snapshot.data![0].docs;
        final zone2Docs = snapshot.data![1].docs;

        
        // Agrupar y contar por persona
        final latestByPerson = <String, Map<String, dynamic>>{};

        // 🔸 Zona 1 (hoy)
        for (var doc in zone1Docs) {
          final data = doc.data() as Map<String, dynamic>;
          final personId = data['epc'][0];
          final timestamp = (data['timestamp'] as Timestamp).toDate();

          latestByPerson[personId] = {
            'zone': 1,
            'timestamp': timestamp,
          };
        }

        // 🔸 Zona 2 (ayer)
        for (var doc in zone2Docs) {
          final data = doc.data() as Map<String, dynamic>;
          final personId = data['epc'][0];
          final timestamp = (data['timestamp'] as Timestamp).toDate();

          // Solo actualiza si es más reciente que el de ayer (simula cambio de zona)
          if (!latestByPerson.containsKey(personId) ||
              timestamp.isAfter(latestByPerson[personId]!['timestamp'])) {
              latestByPerson[personId] = {
                'zone': 2,
                'timestamp': timestamp,
              };
          }
        }

        // Contar personas por zona
        final countPerZone = <int, int>{};
        for (var person in latestByPerson.values) {
          final zone = person['zone'] as int;
          countPerZone[zone] = (countPerZone[zone] ?? 0) + 1;
        }

        return Scaffold(
          appBar: AppBar(),
          body: 
          Column(
          children: [
            const Text(
              'Personas por zona (simulado)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Zona 1 (Hoy)'),
                trailing: Text(
                  '${countPerZone[1] ?? 0}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Zona 2 (Ayer)'),
                trailing: Text(
                  '${countPerZone[2] ?? 0}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
        );
      },
    );
  }
}
