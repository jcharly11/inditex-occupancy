



class MqttDataFirebaseModel {
  final String key;
  final String type;
  final List<dynamic> value;
  
  

  factory MqttDataFirebaseModel.fromMap(Map<String, dynamic> data) {
    return MqttDataFirebaseModel(
      key: data['key'] ?? '', 
      type: data['type'] ?? '',
      value: data['value'] ?? []
    );
  }

  MqttDataFirebaseModel({required this.key, required this.type, required this.value});



  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'type': type,
      'value': value
    };
  }
}
