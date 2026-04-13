class Projeto {
  final int id;
  final String nome;
  final String descricao;

  const Projeto({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  Projeto copyWith({
    int? id,
    String? nome,
    String? descricao,
  }) {
    return Projeto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
    );
  }

  factory Projeto.fromJson(Map<String, dynamic> json) {
    return Projeto(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
    };
  }
}