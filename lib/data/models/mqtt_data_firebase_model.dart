class MqttDataFirebaseModel {
  final int? idEvent;
  final String key;
  final String type;
  final String value;

  MqttDataFirebaseModel({
    this.idEvent,
    required this.key,
    required this.type,
    required this.value,
  });

  factory MqttDataFirebaseModel.fromMap(Map<String, dynamic> map) {
    return MqttDataFirebaseModel(
      idEvent: map['idEvent'] as int?,
      key: map['key'] ?? '',
      type: map['type'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idEvent': idEvent,
      'key': key,
      'type': type,
      'value': value,
    };
  }
}
