// ignore_for_file: body_might_complete_normally_nullable

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:api_consumo/Models/endereco_model.dart';

class ViaCepService {
  Future<Endereco?> buscarEndereco(String cep) async {
    String endpoint = "https://viacep.com.br/ws/$cep/json/";
    Uri uri = Uri.parse(endpoint);

    var response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      Endereco endereco = Endereco.fromJson(json);

      return endereco;
    }
  }
}
