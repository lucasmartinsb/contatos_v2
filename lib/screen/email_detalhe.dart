import 'package:flutter/material.dart';
import 'package:contatos_v2/model/pessoa.dart';
import 'package:contatos_v2/model/email.dart';
import 'package:contatos_v2/bd/banco_helper.dart';

class EmailDetalhe extends StatefulWidget {
  const EmailDetalhe({
    Key? key,
    required this.informacaoEmail,
    required this.informacaoPessoa,
  }) : super(key: key);

  @override
  _EmailDetalheState createState() => _EmailDetalheState();

  final Email informacaoEmail;
  final Pessoa informacaoPessoa;
}

class _EmailDetalheState extends State<EmailDetalhe> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerCdemail = TextEditingController();
  final TextEditingController _controllerCdpes = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var editar;

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerCdemail.dispose();
    _controllerCdpes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.informacaoEmail.cdemail != null) {
      editar = true;
      _controllerCdemail.text = widget.informacaoEmail.cdemail.toString();
      _controllerEmail.text = widget.informacaoEmail.email.toString();
    }
    _controllerCdpes.text = widget.informacaoPessoa.cdpes.toString();

    return AlertDialog(
      title: const Text("Adicionar Email"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controllerEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo Obrigatório.';
                }
                if (!isValidEmail(value)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Salva novo email na lista
              Map<String, dynamic> row = {
                BancoHelper.email: _controllerEmail.text,
                BancoHelper.cdpes: widget.informacaoEmail.cdpes,
              };

              var bdHelper = BancoHelper();

              if (editar == true) {
                bdHelper.editarEmail(Email(
                  cdemail: widget.informacaoEmail.cdemail,
                  email: _controllerEmail.text,
                  cdpes: widget.informacaoPessoa.cdpes,
                ));
              } else {
                await bdHelper.inserir(BancoHelper.tabelaEmail, row);
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
              await bdHelper.deleteEmail(widget.informacaoEmail.cdemail!);
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

bool isValidEmail(String email) {
  final RegExp regex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  return regex.hasMatch(email);
}
