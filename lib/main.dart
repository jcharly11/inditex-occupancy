import 'package:flutter/material.dart';
import 'database_helper.dart'; 

void main() => runApp(ScreenGift());

class ScreenGift extends StatefulWidget {
  @override
  State<ScreenGift> createState() => _ScreenGift();
}

class _ScreenGift extends State<ScreenGift> {
  final dbHelper = BasedatoHelper(); 
  final TextEditingController _controller = TextEditingController(); 
  String? result; 

  @override
  void initState() {
    super.initState();
    dbHelper.insertInitialData(); 
  }

  Future<void> SearchGift(String id) async {
    final mensaje = await dbHelper.consultarYActualizarRegalo(id);
    setState(() {
      result = mensaje; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkpoint UI',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF0A1F44),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 400,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF1E3A8A),
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
                          height: 32,
                        ),
                        Text(
                          'Last Update: 5 seconds ago',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Color(0xFF2D4CC8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'REGALO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 24),
                          TextField(
                            controller: _controller,
                            onSubmitted: SearchGift, 
                            decoration: InputDecoration(
                              hintText: 'Search ID...',
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Color(0xFF466BF2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 24),
                          if (result != null)
                            Text(
                              result!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: ElevatedButton(
                    onPressed: () => _controller.clear(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
