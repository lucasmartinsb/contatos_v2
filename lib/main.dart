import 'package:contatos_v2/bd/banco_helper.dart';
import 'package:contatos_v2/model/contato.dart';
import 'package:contatos_v2/model/pessoa.dart';
import 'package:contatos_v2/screen/pessoa_detalhe.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var bdHelper = BancoHelper();
  final List<Pessoa> _dadosContato = [];
  late List<Pessoa> _contatosFiltrados = [];

  // Carregar toda informacao
  void loadCombinedData() async {
    var r = await bdHelper.buscarPessoas();
    setState(() {
      _dadosContato.clear();
      _dadosContato.addAll(r);
      _contatosFiltrados.clear();
      _contatosFiltrados.addAll(_dadosContato);
      _contatosFiltrados.sort(
          (a, b) => a.nome!.toLowerCase().compareTo(b.nome!.toLowerCase()));
    });
  }

  void removerTudo() async {
    await bdHelper.deletarTodos();
    loadCombinedData();
  }

  @override
  void initState() {
    super.initState();
    bdHelper.iniciarBD().then((value) {
      loadCombinedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pessoas'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  onChanged: (value) {
                    // Atualize a lista de contatos filtrados sempre que o texto da pesquisa mudar
                    setState(() {
                      _contatosFiltrados = _dadosContato
                          .where((contato) => contato.nome!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar por nome',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                _contatosFiltrados.isEmpty
                    ? const Expanded(
                        child: Center(child: Text('Nenhum contato encontrado')),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _contatosFiltrados.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('${_contatosFiltrados[index].nome}'),
                              //Função do click/Toque
                              onTap: () async {
                                final cdpes = _contatosFiltrados[index].cdpes;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FutureBuilder<Pessoa>(
                                      future: bdHelper.getPessoaByCdpes(cdpes!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasError) {
                                            // Handle error
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return PessoaDetalhe(
                                              informacaoPessoa: snapshot.data!,
                                            );
                                          }
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  ),
                                ).then((_) async {
                                  loadCombinedData();
                                });
                              },
                            );
                          },
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // remover todos
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          removerTudo();
                          loadCombinedData();
                        },
                        child: const Text(
                          'Deletar tudo',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 70, 70),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Alinha botoes numa row
          children: [
            // adicionar pessoa
            Builder(
              builder: (BuildContext context) {
                return FloatingActionButton(
                  heroTag: "addPessoa",
                  backgroundColor: Color.fromARGB(255, 10, 132, 255),
                  child: const Icon(
                    Icons.person_add,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    //inserirRegistro();
                    Pessoa value = Pessoa(cdpes: null, nome: null, idade: null);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PessoaDetalhe(informacaoPessoa: value),
                      ),
                    ).then((_) {
                      loadCombinedData();
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
