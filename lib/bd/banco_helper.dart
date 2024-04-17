import 'dart:async';
import 'package:contatos_v2/model/contato.dart';
import 'package:contatos_v2/model/email.dart';
import 'package:contatos_v2/model/pessoa.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:contatos_v2/model/telefone.dart';

class BancoHelper {
  static const arquivoDoBancoDeDados = 'nossoBD.db';
  static const arquivoDoBancoDeDadosVersao = 1;

  static const tabelaPessoas = 'pessoas';
  static const cdpes = 'cdpes';
  static const nome = 'nome';
  static const idade = 'idade';

  static const tabelaTelefones = 'telefones';
  static const cdfone = 'cdfone';
  static const fone = 'fone';
  static const ddd = 'ddd';

  static const tabelaEmail = 'emails';
  static const cdemail = 'cdemail';
  static const email = 'email';

  static late Database db;

  iniciarBD() async {
    String caminhoBD = await getDatabasesPath();
    String path = join(caminhoBD, arquivoDoBancoDeDados);

    db = await openDatabase(path,
        version: arquivoDoBancoDeDadosVersao,
        onCreate: funcaoCriacaoBD,
        onUpgrade: funcaoAtualizarBD,
        onDowngrade: funcaoDowngradeBD);
  }

  Future funcaoCriacaoBD(Database db, int version) async {
    await db.execute('''
        CREATE TABLE pessoas (
          cdpes INTEGER PRIMARY KEY,
          nome TEXT NOT NULL,
          idade INTEGER NOT NULL
        )
      ''');

    await db.execute('''
        CREATE TABLE telefones (
          cdfone INTEGER PRIMARY KEY,
          cdpes INTEGER NOT NULL,
          fone TEXT NOT NULL,
          ddd INTEGER NOT NULL,
          FOREIGN KEY (cdpes) REFERENCES pessoas (cdpes)
        )
      ''');

    await db.execute('''
        CREATE TABLE emails (
          cdemail INTEGER PRIMARY KEY,
          cdpes INTEGER NOT NULL,
          email TEXT NOT NULL,
          FOREIGN KEY (cdpes) REFERENCES pessoas (cdpes)
        )
      ''');
  }

  Future funcaoAtualizarBD(Database db, int oldVersion, int newVersion) async {
    //controle dos comandos sql para novas versões

    if (oldVersion < 2) {
      //Executa comandos
    }
  }

  Future funcaoDowngradeBD(Database db, int oldVersion, int newVersion) async {
    //controle dos comandos sql para voltar versãoes.
    //Estava-se na 2 e optou-se por regredir para a 1
  }

  // Inserir registro no bd
  Future<int> inserir(tabela, Map<String, dynamic> row) async {
    await iniciarBD();
    return await db.insert(tabela, row);
  }

  // Deleta todas as pessoas
  Future<int> deletarTodos() async {
    await iniciarBD();
    db.delete(tabelaTelefones);
    db.delete(tabelaEmail);
    return db.delete(tabelaPessoas);
  }

  Future<void> deletarPessoa(int codigo) async {
    await iniciarBD();
    db.delete(
      tabelaTelefones,
      where: '$cdpes = ?',
      whereArgs: [codigo],
    );
    db.delete(
      tabelaEmail,
      where: '$cdpes = ?',
      whereArgs: [codigo],
    );
    db.delete(
      tabelaPessoas,
      where: '$cdpes = ?',
      whereArgs: [codigo],
    );
  }

  //Carregar pessoas tela inicial
  Future<List<Pessoa>> buscarPessoas() async {
    await iniciarBD();

    final List<Map<String, Object?>> pessoasNoBanco =
        await db.query(tabelaPessoas);

    return [
      for (final {
            cdpes: pId as int,
            nome: pNome as String,
            idade: pIdade as int,
          } in pessoasNoBanco)
        Pessoa(cdpes: pId, nome: pNome, idade: pIdade),
    ];
  }

  // Editar pessoas
  Future<void> editarPessoa(Pessoa regPessoa) async {
    await iniciarBD();

    await db.update(
      tabelaPessoas,
      regPessoa.toMap(),
      where: '$cdpes = ?',
      whereArgs: [regPessoa.cdpes],
    );
  }

  // Editar telefone
  Future<void> editarTelefone(Telefone regTelefone) async {
    await iniciarBD();

    await db.update(
      tabelaTelefones,
      regTelefone.toMap(),
      where: '$cdfone = ?',
      whereArgs: [regTelefone.cdfone],
    );
  }

  // Editar email
  Future<void> editarEmail(Email regEmail) async {
    await iniciarBD();

    await db.update(
      tabelaEmail,
      regEmail.toMap(),
      where: '$cdemail = ?',
      whereArgs: [regEmail.cdemail],
    );
  }

  // Select para lista inicial
  Future<List<Contato>> getCombinedData() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('''
      SELECT 
      pessoas.cdpes, 
      pessoas.nome, 
      GROUP_CONCAT(telefones.ddd || ' ' || telefones.fone, ', ') as telefones,
      GROUP_CONCAT(emails.email, ', ') as emails
    FROM pessoas
    LEFT JOIN telefones ON pessoas.cdpes = telefones.cdpes
    LEFT JOIN emails ON pessoas.cdpes = emails.cdpes
    GROUP BY pessoas.cdpes
    ''');

    return result
        .map((row) => Contato(
              id: row['cdpes'] as int,
              nome: row['nome'] as String,
              telefones: (row['telefones'] as String?)?.split(', ') ?? [],
              emails: (row['emails'] as String?)?.split(', ') ?? [],
            ))
        .toList();
  }

  Future<List<Telefone>> getTelefonesList(int codigo) async {
    await iniciarBD();

    final List<Map<String, Object?>> telefonesContato = await db.query(
      tabelaTelefones,
      where: '$cdpes = ?',
      whereArgs: [codigo],
    );

    List<Telefone> listaTelefones = telefonesContato.map((telefoneMap) {
      return Telefone.fromMap(telefoneMap);
    }).toList();

    return listaTelefones;
  }

  Future<List<Email>> getEmailsList(int codigo) async {
    await iniciarBD();

    final List<Map<String, Object?>> emailsContato = await db.query(
      tabelaEmail,
      where: '$cdpes = ?',
      whereArgs: [codigo],
    );

    List<Email> listaEmails = emailsContato.map((emailMap) {
      return Email.fromMap(emailMap);
    }).toList();

    return listaEmails;
  }

  // SELECT * FROM pessoas WHERE cdpes = ?
  Future<Pessoa> getPessoaByCdpes(int id) async {
    await iniciarBD();

    final List<Map<String, Object?>> pessoasNoBanco = await db.query(
      tabelaPessoas,
      where: '$cdpes = ?',
      whereArgs: [id],
    );

    return Pessoa.fromMap(pessoasNoBanco.first);
  }

  Future<Telefone> getTelefoneByCdFone(int codigo) async {
    await iniciarBD();

    final List<Map<String, Object?>> telefoneNoBanco = await db.query(
      tabelaTelefones,
      where: '$cdfone = ?',
      whereArgs: [codigo],
    );

    return Telefone.fromMap(telefoneNoBanco.first);
  }

  Future<int> deleteTelefone(int codigo) async {
    await iniciarBD();

    return await db.delete(
      tabelaTelefones,
      where: '$cdfone = ?',
      whereArgs: [codigo],
    );
  }

  Future<int> deleteEmail(int codigo) async {
    await iniciarBD();

    return await db.delete(
      tabelaEmail,
      where: 'cdemail = ?',
      whereArgs: [codigo],
    );
  }
}
