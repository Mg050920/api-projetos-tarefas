import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'package:backend/models/projeto.dart';
import 'package:backend/models/tarefa.dart';
import 'package:backend/routes/projeto_routes.dart';
import 'package:backend/routes/tarefa_routes.dart';

const Map<String, String> _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};

Middleware corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(
        headers: {
          ...response.headers,
          ..._corsHeaders,
        },
      );
    };
  };
}

void main() async {
  final projetos = <Projeto>[
    const Projeto(
      id: 1,
      nome: 'API de Projetos e Tarefas',
      descricao: 'Trabalho da disciplina de Tópicos Especiais',
    ),
  ];

  final tarefas = <Tarefa>[
    const Tarefa(
      id: 1,
      titulo: 'Estruturar a API em Dart',
      status: 'pendente',
      projetoId: 1,
    ),
    const Tarefa(
      id: 2,
      titulo: 'Organizar os testes no Postman',
      status: 'pendente',
      projetoId: 1,
    ),
  ];

  final pipeline = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware());

  final app = pipeline.addHandler(
    Cascade()
        .add(projetoRoutes(projetos, tarefas))
        .add(tarefaRoutes(tarefas, projetos))
        .handler,
  );

  final server = await io.serve(
    app,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Servidor rodando em http://${server.address.host}:${server.port}');
}