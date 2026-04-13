class Tarefa {
  final int id;
  final String titulo;
  final String status;
  final int projetoId;

  const Tarefa({
    required this.id,
    required this.titulo,
    required this.status,
    required this.projetoId,
  });

  Tarefa copyWith({
    int? id,
    String? titulo,
    String? status,
    int? projetoId,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      status: status ?? this.status,
      projetoId: projetoId ?? this.projetoId,
    );
  }

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      status: json['status'] as String,
      projetoId: json['projetoId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'status': status,
      'projetoId': projetoId,
    };
  }
}