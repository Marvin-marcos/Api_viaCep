
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api_consumo/Models/endereco_model.dart';
import 'package:api_consumo/Services/via_cep_service.dart';
import 'package:api_consumo/Pages/mapa_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  TextEditingController controllerCep = TextEditingController();
  TextEditingController controllerLogradouro = TextEditingController();
  TextEditingController controllerComplemento = TextEditingController();
  TextEditingController controllerBairro = TextEditingController();
  TextEditingController controllerCidade = TextEditingController();
  TextEditingController controllerEstado = TextEditingController();

  Endereco? endereco;
  bool isLoading = false;

  ViaCepService viaCepService = ViaCepService();

  Future<void> buscarCep(String cep) async {
    clearControllers();
    setState(() {
      isLoading = true;
    });
    try {
      Endereco? response = await viaCepService.buscarEndereco(cep);

      if (response?.localidade == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: Icon(Icons.warning, color: Colors.orange, size: 40),
              title: Text("Atenção", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text("Cep não encontrado"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        controllerCep.clear();
        return;
      }

      setState(() {
        endereco = response;
      });

      setControllersCep(endereco!);
    } catch (erro) {
      throw Exception("Erro ao buscar CEP: $erro");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void setControllersCep(Endereco endereco) {
    controllerLogradouro.text = endereco.logradouro ?? '';
    controllerComplemento.text = endereco.complemento ?? '';
    controllerBairro.text = endereco.bairro ?? '';
    controllerCidade.text = endereco.localidade ?? '';
    controllerEstado.text = endereco.estado ?? '';
  }

  void clearControllers() {
    controllerBairro.clear();
    controllerLogradouro.clear();
    controllerCidade.clear();
    controllerComplemento.clear();
    controllerEstado.clear();
  }

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Text("ViaCEP Api", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 2,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(28),
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Consulta de CEP",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    onChanged: (valor) {
                      if (valor.isEmpty) {
                        setState(() {
                          endereco = null;
                        });
                        clearControllers();
                      }
                    },
                    controller: controllerCep,
                    maxLength: 8,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: customInputDecoration("CEP").copyWith(
                      suffixIcon: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              buscarCep(controllerCep.text);
                            },
                      icon: Icon(Icons.search, color: Colors.white),
                      label: Text(
                        "Buscar CEP",
                        style: TextStyle(fontSize:16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (endereco?.bairro != null)
                    Column(
                      children: [
                        TextField(
                          controller: controllerLogradouro,
                          decoration: customInputDecoration("Logradouro"),
                          readOnly: true,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: controllerComplemento,
                          decoration: customInputDecoration("Complemento"),
                          readOnly: true,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: controllerBairro,
                          decoration: customInputDecoration("Bairro"),
                          readOnly: true,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: controllerCidade,
                          decoration: customInputDecoration("Cidade"),
                          readOnly: true,
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: controllerEstado,
                          decoration: customInputDecoration("Estado"),
                          readOnly: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapaPage(
                                  latitude: -23.55052, // substituir pelos valores reais do CEP
                                  longitude: -46.633308,
                                ),
                              ),
                            );
                          },
                          child: const Text('Ver no mapa'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
