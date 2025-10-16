import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

class BasedatoHelper {
  final _store = stringMapStoreFactory.store("regalos"); 
  final _factory = databaseFactoryWeb; 

  Database? _db;

  Future<Database> _openDB() async {
    _db ??= await _factory.openDatabase("gift.db");
    return _db!;
  }

  Future<void> insertInitialData() async {
    final db = await _openDB();
    final existing = await _store.find(db);
    if (existing.isNotEmpty) return;

    final regalos = []; 

    for (var r in regalos) {
      await _store.record(r['id']!).put(db, r);
    }
  }

  Future<Map<String, dynamic>?> getRegaloById(String id) async {
    final db = await _openDB();
    return await _store.record(id).get(db);
  }

  Future<int> getGiftCount() async {
    final db = await _openDB();
    final records = await _store.find(db);
    return records.length;
  }

  //consulta un ID y actualiza o crea el registro según sea necesario.
  //Si el ID no existe, lo añade con regalo "si" y fecha/hora.
  //Si existe con "no", lo actualiza a "si" y añade fecha/hora.
  //Si ya tiene "si", no hace nada.
  Future<String> consultarYActualizarRegalo(String id) async {
    final db = await _openDB();

    final registro = await getRegaloById(id);

    if (registro == null) {
      final nuevo = {
        'id': id,
        'regalo': 'si',
        'fechaHora': DateTime.now().toIso8601String(),
      };
      await _store.record(id).put(db, nuevo);
      return 'ID $id añadido con regalo';
    } else if (registro['regalo'] == 'no') {
      final actualizado = {
        'id': id,
        'regalo': 'si',
        'fechaHora': DateTime.now().toIso8601String(),
      };
      await _store.record(id).put(db, actualizado);
      return 'ID $id actualizado a regalo entregado';
    } else {
      return 'ID $id ya tiene regalo';
    }
  }
}
