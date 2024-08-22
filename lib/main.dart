import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json&key=60df7606";

void main() async {
  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
  //return json.decode(response.body)['results']['currencies']['USD'];
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    // this.dolar faz referencia à variavel dolar da clase e diferencia da
    // variavel do escopo local com mesmo nome.
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    'Carregando Dados...',
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Erro carregando dados...',
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data?['results']['currencies']['USD']['buy'];
                  euro = snapshot.data?['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          buildTextField('Reais', 'R\$ ', realController, _realChanged),
                          const Divider(color: Colors.black,),
                          buildTextField('Dólares', 'US\$ ', dolarController, _dolarChanged),
                          const Divider(color: Colors.black,),
                          buildTextField('Euros', '€ ', euroController, _euroChanged),
                          const Divider(color: Colors.black,),
                          Text(
                            'Cotação do Dolar: R\$ ${dolar}',
                            style: const TextStyle(color: Colors.amber, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(),
                          Text(
                            'Cotação do Euro: R\$ ${euro}',
                            style: const TextStyle(color: Colors.amber, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c,
    Function(String text) f) {
  return TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true, ),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber, fontSize: 25),
        border: const OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.amber, fontSize: 25),
        focusedBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber))),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: f,
  );
}
