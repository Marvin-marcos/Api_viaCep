import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cep_model.dart';

class CepService {
  Future<CepModel?> fetchCepFromApi(String cep) async {
    final sanitized = cep.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://viacep.com.br/ws/$sanitized/json/');

    final resp = await http.get(url);
    if (resp.statusCode != 200) return null;

    final json = jsonDecode(resp.body);
    if (json['erro'] == true) return null;

    return CepModel.fromJson(Map<String, dynamic>.from(json));
  }
}
