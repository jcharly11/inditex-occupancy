class EventsFirebaseModel {
  final int? id;
  final String uuid;
  final String accountNumber;
  final String storeId;
  final String eventId;
  final int silent;
  final String groupId;
  final int timestamp;
  final String deviceId;
  final String deviceModel;
  final String technology;
  final String doorName;

  EventsFirebaseModel({
    this.id,
    required this.uuid,
    required this.accountNumber,
    required this.storeId,
    required this.eventId,
    required this.silent,
    required this.groupId,
    required this.timestamp,
    required this.deviceId,
    required this.deviceModel,
    required this.technology,
    required this.doorName,
  });

  factory EventsFirebaseModel.fromMap(Map<String, dynamic> map) {
    return EventsFirebaseModel(
      id: map['id'] as int?,
      uuid: map['uuid'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      storeId: map['storeId'] ?? '',
      eventId: map['eventId'] ?? '',
      silent: map['silent'] ?? 0,
      groupId: map['groupId'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      deviceId: map['deviceId'] ?? '',
      deviceModel: map['deviceModel'] ?? '',
      technology: map['technology'] ?? '',
      doorName: map['doorName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'accountNumber': accountNumber,
      'storeId': storeId,
      'eventId': eventId,
      'silent': silent,
      'groupId': groupId,
      'timestamp': timestamp,
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'technology': technology,
      'doorName': doorName,
    };
  }
}
