import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  final String broker;
  final int port;
  final String clientId;
  final String topic;

  late MqttServerClient client;

  MQTTService({
    this.broker = 'test.mosquitto.org',
    this.port = 1883,
    this.clientId = 'flutter_client_menie',
    this.topic = 'test/menie/topic',
  }) {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    client.onConnected = () => print('✅ Conectado al broker MQTT');
    client.onDisconnected = () => print('⛔ Desconectado del broker');
    client.onSubscribed = (topic) => print('📡 Suscrito a $topic');
  }

  Future<void> connect() async {
    try {
      print('🔌 Intentando conectar...');
      await client.connect();
    } catch (e) {
      print('❌ Error de conexión: $e');
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('✅ Conexión exitosa');
    } else {
      print('❌ No se pudo conectar');
      client.disconnect();
    }
  }

  void publish(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('✉️ Enviando mensaje: "$message" a $topic');
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    print('⛔ Cerrando conexión MQTT');
    client.disconnect();
  }
}

