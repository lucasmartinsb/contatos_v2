import 'package:contatos_v2/main.dart';
import 'package:contatos_v2/model/email.dart';
import 'package:contatos_v2/model/pessoa.dart';
import 'package:flutter/material.dart';
import 'package:contatos_v2/bd/banco_helper.dart';
import 'package:contatos_v2/model/telefone.dart';
import 'package:contatos_v2/screen/email_detalhe.dart';
import 'package:contatos_v2/screen/telefone_detalhe.dart';
import 'package:flutter/services.dart';

class PessoaDetalhe extends StatefulWidget {
  const PessoaDetalhe({super.key, required this.informacaoPessoa});

  @override
  _PessoaDetalheState createState() => _PessoaDetalheState();

  final Pessoa informacaoPessoa;
}

class _PessoaDetalheState extends State<PessoaDetalhe> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerID = TextEditingController();
  final TextEditingController _controllerIdade = TextEditingController();
  List<Telefone> _dadosTelefones = [];
  List<Email> _dadosEmails = [];
  final _formKey = GlobalKey<FormState>();
  var editar;
  var bdHelper = BancoHelper();

  @override
  void dispose() {
    _controllerNome.dispose();
    super.dispose();
  }

  Future<void> carregarTelefones() async {
    var bdHelper = BancoHelper();
    if (widget.informacaoPessoa.cdpes != null) {
      List<Telefone> telefones =
          await bdHelper.getTelefonesList(widget.informacaoPessoa.cdpes!);
      if (mounted) {
        setState(() {
          _dadosTelefones = telefones;
        });
      }
    }
  }

  Future<void> carregarEmails() async {
    var bdHelper = BancoHelper();
    if (widget.informacaoPessoa.cdpes != null) {
      List<Email> emails =
          await bdHelper.getEmailsList(widget.informacaoPessoa.cdpes!);
      if (mounted) {
        setState(() {
          _dadosEmails = emails;
        });
      }
    }
  }

  void _mostrarPopupTelefone(BuildContext context, Telefone informacaoTelefone,
      Pessoa informacaoPessoa) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return TelefoneDetalhe(
              informacaoTelefone: informacaoTelefone,
              informacaoPessoa: informacaoPessoa);
        }).then((_) {
      carregarTelefones();
    });
  }

  void _mostrarPopupEmail(
      BuildContext context, Email informacaoEmail, Pessoa informacaoPessoa) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return EmailDetalhe(
              informacaoEmail: informacaoEmail,
              informacaoPessoa: informacaoPessoa);
        }).then((_) {
      carregarEmails();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.informacaoPessoa.cdpes != null) {
      editar = true;
      _controllerID.text = widget.informacaoPessoa.cdpes.toString();
      _controllerNome.text = widget.informacaoPessoa.nome.toString();
      _controllerIdade.text = widget.informacaoPessoa.idade.toString();
      carregarTelefones();
      carregarEmails();
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<int> salvarContato() async {
      // Salva nova pessoa na lista
      Map<String, dynamic> row = {
        BancoHelper.nome: _controllerNome.text,
        BancoHelper.idade: _controllerIdade.text
      };

      if (editar == true) {
        widget.informacaoPessoa.nome = _controllerNome.text;
        widget.informacaoPessoa.idade = int.parse(_controllerIdade.text);
        bdHelper.editarPessoa(widget.informacaoPessoa);
        return widget.informacaoPessoa.cdpes!;
      } else {
        final id = await bdHelper.inserir(BancoHelper.tabelaPessoas, row);
        return id;
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Container(
                color: Color.fromARGB(1, 253, 252, 252),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        controller: _controllerNome,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        controller: _controllerIdade,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(3),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Idade',
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
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: const Color.fromARGB(255, 10, 132, 255),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Telefones',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 10, 132, 255)),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _dadosTelefones.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(
                              '${_dadosTelefones[index].ddd} ${_dadosTelefones[index].fone}',
                            ),
                            onTap: () {
                              Pessoa valuePessoa = Pessoa(
                                  cdpes: widget.informacaoPessoa.cdpes,
                                  nome: widget.informacaoPessoa.nome,
                                  idade: widget.informacaoPessoa.idade);
                              _mostrarPopupTelefone(
                                  context, _dadosTelefones[index], valuePessoa);
                            });
                      },
                    ),
                    ListTile(
                      title: Text("Adicionar telefone"),
                      textColor: const Color.fromARGB(255, 10, 132, 255),
                      onTap: () async {
                        widget.informacaoPessoa.cdpes = await salvarContato();
                        editar = true;
                        Telefone valueTelefone = Telefone(
                          cdfone: null,
                          fone: null,
                          ddd: null,
                          cdpes: widget.informacaoPessoa.cdpes,
                        );

                        Pessoa valuePessoa = Pessoa(
                          cdpes: widget.informacaoPessoa.cdpes,
                          nome: widget.informacaoPessoa.nome,
                          idade: widget.informacaoPessoa.idade,
                        );

                        _mostrarPopupTelefone(
                            context, valueTelefone, valuePessoa);
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.centerLeft,
                      //padding: const EdgeInsets.all(20),
                      child: Container(
                          child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color:
                                        const Color.fromARGB(255, 10, 132, 255),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'E-mails',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 10, 132, 255)),
                                  ),
                                ],
                              ))),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _dadosEmails.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(
                              '${_dadosEmails[index].email}',
                            ),
                            onTap: () async {
                              widget.informacaoPessoa.cdpes =
                                  await salvarContato();
                              editar = true;
                              Pessoa valuePessoa = Pessoa(
                                  cdpes: widget.informacaoPessoa.cdpes,
                                  nome: widget.informacaoPessoa.nome,
                                  idade: widget.informacaoPessoa.idade);
                              _mostrarPopupEmail(
                                  context, _dadosEmails[index], valuePessoa);
                            });
                      },
                    ),
                    ListTile(
                      title: Text("Adicionar e-mail"),
                      textColor: const Color.fromARGB(255, 10, 132, 255),
                      onTap: () async {
                        int id = await salvarContato();
                        Email valueEmail = Email(
                          email: null,
                          cdpes: id,
                        );

                        Pessoa valuePessoa = Pessoa(
                          cdpes: widget.informacaoPessoa.cdpes,
                          nome: widget.informacaoPessoa.nome,
                          idade: widget.informacaoPessoa.idade,
                        );

                        _mostrarPopupEmail(context, valueEmail, valuePessoa);
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              salvarContato();
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(
                                255, 10, 132, 255),
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          )),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: ElevatedButton(
                          onPressed: widget.informacaoPessoa.cdpes != null
                              ? () async {
                                  bdHelper.deletarPessoa(
                                      widget.informacaoPessoa.cdpes!);
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(1, 233, 232, 235),
                          ),
                          child: Text(
                            'Deletar',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 70, 70),
                            ),
                          ),
                        )),
                  ],
                ),
              ))),
    );
  }
}
