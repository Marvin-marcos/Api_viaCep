// ignore_for_file: file_names

class CepModel {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  CepModel({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory CepModel.fromJson(Map<String, dynamic> json) => CepModel(
        cep: (json['cep'] ?? '').toString(),
        logradouro: (json['logradouro'] ?? '').toString(),
        bairro: (json['bairro'] ?? '').toString(),
        localidade: (json['localidade'] ?? '').toString(),
        uf: (json['uf'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'cep': cep,
        'logradouro': logradouro,
        'bairro': bairro,
        'localidade': localidade,
        'uf': uf,
      };
}
