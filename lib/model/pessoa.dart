class Pessoa {
  int? cdpes;
  String? nome;
  int? idade;

  Pessoa({
    this.cdpes,
    this.nome,
    this.idade,
  });

  Map<String, Object?> toMap() {
    return {
      'cdpes': cdpes,
      'nome': nome,
      'idade': idade,
    };
  }

  @override
  String toString() {
    return 'Pessoa { nome: $nome, idade: $idade}';
  }

  static Future<Pessoa> fromMap(Map<String, Object?> first) {
    return Future.value(Pessoa(
      cdpes: first['cdpes'] as int,
      nome: first['nome'] as String,
      idade: first['idade'] as int,
    ));
  }
}
