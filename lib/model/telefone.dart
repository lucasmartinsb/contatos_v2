class Telefone {
  int? cdfone;
  String? fone;
  int? ddd;
  int? cdpes;

  Telefone({
    this.cdfone,
    this.fone,
    this.ddd,
    this.cdpes,
  });

  Map<String, Object?> toMap() {
    return {
      'cdfone': cdfone,
      'fone': fone,
      'ddd': ddd,
      'cdpes': cdpes,
    };
  }

  factory Telefone.fromMap(Map<String, dynamic> map) {
    return Telefone(
        cdfone: map['cdfone'],
        fone: map['fone'],
        ddd: map['ddd'],
        cdpes: map['cdpes']);
  }

  @override
  String toString() {
    return 'Telefone { fone: ($ddd) $fone}';
  }
}
