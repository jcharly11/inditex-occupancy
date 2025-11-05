class EnrichFirebaseModel {
  final int? idEvent;
  final String uuid;
  final String category;
  final String description;
  final String epc;
  final String imageUrl;
  final String price;
  final String sku;
  final String gtin;

  EnrichFirebaseModel({
    this.idEvent,
    required this.uuid,
    required this.category,
    required this.description,
    required this.epc,
    required this.imageUrl,
    required this.price,
    required this.sku,
    required this.gtin,
  });

  factory EnrichFirebaseModel.fromMap(Map<String, dynamic> map) {
    return EnrichFirebaseModel(
      idEvent: map['idEvent'] as int?,
      uuid: map['uuid'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      epc: map['epc'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] ?? '',
      sku: map['sku'] ?? '',
      gtin: map['gtin'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idEvent': idEvent,
      'uuid': uuid,
      'category': category,
      'description': description,
      'epc': epc,
      'imageUrl': imageUrl,
      'price': price,
      'sku': sku,
      'gtin': gtin,
    };
  }
}
