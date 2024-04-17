import 'package:contatos_v2/main.dart';
import 'package:contatos_v2/model/pessoa.dart';
import 'package:contatos_v2/model/telefone.dart';
import 'package:flutter/material.dart';
import 'package:contatos_v2/bd/banco_helper.dart';
import 'package:flutter/services.dart';

class TelefoneDetalhe extends StatefulWidget {
  const TelefoneDetalhe({
    Key? key,
    required this.informacaoTelefone,
    required this.informacaoPessoa,
  }) : super(key: key);

  @override
  _TelefoneDetalheState createState() => _TelefoneDetalheState();

  final Telefone informacaoTelefone;
  final Pessoa informacaoPessoa;
}

class _TelefoneDetalheState extends State<TelefoneDetalhe> {
  final TextEditingController _controllerFone = TextEditingController();
  final TextEditingController _controllerDdd = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var editar;

  @override
  void dispose() {
    _controllerFone.dispose();
    _controllerDdd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.informacaoTelefone.cdfone != null) {
      editar = true;
      _controllerFone.text = widget.informacaoTelefone.fone.toString();
      _controllerDdd.text = widget.informacaoTelefone.ddd.toString();
    }

    return AlertDialog(
      title: const Text("Adicionar telefone"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 20),
                  child: TextFormField(
                    controller: _controllerDdd,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(2),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'DDD',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo Obrigatório.';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                    child: Container(
                  child: TextFormField(
                    controller: _controllerFone,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(9),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo Obrigatório.';
                      }
                      return null;
                    },
                  ),
                ))
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Salva novo telefone na lista
              Map<String, dynamic> row = {
                BancoHelper.fone: _controllerFone.text,
                BancoHelper.ddd: _controllerDdd.text,
                BancoHelper.cdpes: widget.informacaoTelefone.cdpes,
              };

              var bdHelper = BancoHelper();

              if (editar == true) {
                bdHelper.editarTelefone(Telefone(
                  cdfone: widget.informacaoTelefone.cdfone,
                  cdpes: widget.informacaoTelefone.cdpes,
                  fone: _controllerFone.text,
                  ddd: int.parse(_controllerDdd.text),
                ));
              } else {
                await bdHelper.inserir(BancoHelper.tabelaTelefones, row);
              }
              Navigator.pop(context); // Fecha o popup
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 10, 132, 255),
          ),
          child: const Text(
            'Salvar',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            var bdHelper = BancoHelper();
            if (editar == true) {
              await bdHelper.deleteTelefone(widget.informacaoTelefone.cdfone!);
              Navigator.pop(context); // Fecha o popup
            } else {
              Navigator.pop(context); // Fecha o popup
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(1, 233, 232, 235),
          ),
          child: const Icon(
            Icons.delete,
            color: Color.fromARGB(255, 255, 70, 70),
          ),
        ),
      ],
    );
  }
}
