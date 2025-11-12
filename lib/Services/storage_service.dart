import 'package:hive/hive.dart';
import '../models/cep_model.dart';

class StorageService {
  final Box _box = Hive.box('cepsBox');

  Future<void> saveCep(CepModel cep) async {
    final key = cep.cep.replaceAll('-', '');
    await _box.put(key, cep.toJson());
  }

  CepModel? getCep(String cep) {
    final key = cep.replaceAll('-', '');
    final data = _box.get(key);
    if (data == null) return null;

    return CepModel.fromJson(Map<String, dynamic>.from(data));
  }

  List<CepModel> getAllCeps() {
    return _box.keys.map((k) {
      final data = Map<String, dynamic>.from(_box.get(k));
      return CepModel.fromJson(data);
    }).toList();
  }
}
