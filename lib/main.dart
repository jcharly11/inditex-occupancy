import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OccupancyDashboard(),
  ));
}

class OccupancyDashboard extends StatelessWidget {
  const OccupancyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 780, 
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 22, 56, 78), 
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/checkpoint_logo_bco2.png',
                            height: 40,
                          ),
                          const Text(
                            'Last update: 5 seconds ago',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 66, 101, 128), 
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                SimpleLabel(label: 'People inside: 310'),
                                SimpleLabel(label: 'Max Occupancy: 458'),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: const [
                                    LargeRectInfo(label: 'Realtime Occupancy', value: '310', width: 200),
                                    SizedBox(height: 16),
                                    RectangularInfo(label: 'Employees inside', value: '100', width: 180),
                                    SizedBox(height: 16),
                                    RectangularInfo(label: 'Family & Friends', value: '210', width: 180),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    LargeRectInfo(label: 'Available Places', value: '148', width: 200),
                                    const SizedBox(height: 48),
                                    SizedBox(
                                      width: 220,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Search ID...',
                                          prefixIcon: const Icon(Icons.search),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 64.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 121, 4, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SimpleLabel extends StatelessWidget {
  final String label;

  const SimpleLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, color: Colors.white),
    );
  }
}

class RectangularInfo extends StatelessWidget {
  final String label;
  final String value;
  final double labelFontSize;
  final double valueFontSize;
  final double width;

  const RectangularInfo({
    super.key,
    required this.label,
    required this.value,
    this.labelFontSize = 10,
    this.valueFontSize = 15,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 75,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: labelFontSize, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class LargeRectInfo extends StatelessWidget {
  final String label;
  final String value;
  final double labelFontSize;
  final double valueFontSize;
  final double width;

  const LargeRectInfo({
    super.key,
    required this.label,
    required this.value,
    this.labelFontSize = 12,
    this.valueFontSize = 56,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: labelFontSize, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
