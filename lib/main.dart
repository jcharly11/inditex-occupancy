import 'package:flutter/material.dart';
import 'services/mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mqtt = MQTTService(); // Usamos la clase que creaste

  @override
  void initState() {
    super.initState();
    conectarMQTT(); // Nos conectamos al iniciar la app
  }

  Future<void> conectarMQTT() async {
    await mqtt.connect();
    mqtt.publish("Hola desde Flutter 💫");
  }

  @override
  void dispose() {
    mqtt.disconnect(); // Cerramos conexión al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Cliente MQTT')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('MQTT conectado '),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  mqtt.publish("Mensaje desde el botón ");
                },
                child: const Text("Enviar mensaje"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
