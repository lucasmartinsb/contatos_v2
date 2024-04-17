class Email {
  int? cdemail;
  String? email;
  int? cdpes;

  Email({
    this.cdemail,
    this.email,
    this.cdpes,
  });

  Map<String, Object?> toMap() {
    return {
      'cdemail': cdemail,
      'email': email,
      'cdpes': cdpes,
    };
  }

  factory Email.fromMap(Map<String, dynamic> map) {
    // Extrair os dados do mapa
    int cdemail = map['cdemail'];
    String email = map['email'];

    // Retornar uma instância de Email com os dados extraídos
    return Email(
      cdemail: cdemail,
      email: email,
    );
  }

  @override
  String toString() {
    return 'Email { email: $email}';
  }
}
