import 'dart:async';
import 'package:api_consumo/Pages/connectivivy_page.dart';
import 'package:flutter/material.dart';
import '../services/cep_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import '../models/cep_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

@override
  // ignore: library_private_types_in_public_api
  _ConnectivityPageState createState() => _ConnectivityPageState();
  
class _ConnectivityPageState extends State<ConnectivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status de Conectividade")),
      body: Center(child: Column(children: [Icon(Icons.wifi)])),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final cepController = TextEditingController();
  final cepService = CepService();
  final storageService = StorageService();
  final connectivityService = ConnectivityService();

  bool isOnline = false;
  bool isLoading = false;

  List<CepModel> savedCeps = [];

  StreamSubscription<bool>? connSub;




  String _sanitizeCep(String cep) {
    return cep.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> consultCep() async {
    final cep = _sanitizeCep(cepController.text.trim());

    if (cep.isEmpty || cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um CEP válido (8 números).")),
      );
      return;
    }

    setState(() => isLoading = true);

    CepModel? model;

    if (isOnline) {
      model = await cepService.fetchCepFromApi(cep);
      if (model != null) {
        await storageService.saveCep(model);
        setState(() => savedCeps = storageService.getAllCeps());
      }
    } else {
      model = storageService.getCep(cep);
    }

    setState(() => isLoading = false);

    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isOnline
                ? 'CEP não encontrado na API.'
                : 'CEP não encontrado localmente (modo offline).')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("CEP: ${model!.cep}"),
        content: Text(
            "${model.logradouro}\n${model.bairro}\n${model.localidade} - ${model.uf}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    connSub?.cancel();
    cepController.dispose();
    connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta CEP"),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? "Online" : "Offline",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: cepController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: "CEP",
                hintText: "Digite o CEP (somente números)",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => cepController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: "",
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : consultCep,
                icon: const Icon(Icons.search),
                label: Text(isLoading ? "Buscando..." : "Consultar"),
              ),
            ),

            if (!isOnline)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Modo Offline: buscando apenas CEPs salvos.",
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CEPs Salvos:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: savedCeps.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum CEP salvo ainda",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: savedCeps.length,
                      itemBuilder: (_, i) {
                        final c = savedCeps[i];

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(c.cep),
                            subtitle: Text(
                                "${c.logradouro}\n${c.localidade} - ${c.uf}"),
                            isThreeLine: true,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("CEP: ${c.cep}"),
                                  content: Text(
                                      "${c.logradouro}\n${c.bairro}\n${c.localidade} - ${c.uf}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("Fechar"),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
