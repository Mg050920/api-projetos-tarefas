import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:backend/models/projeto.dart';
import 'package:backend/models/tarefa.dart';

Router projetoRoutes(List<Projeto> projetos, List<Tarefa> tarefas) {
  final router = Router();

  router.get('/projetos', (Request request) {
    final resposta = projetos.map((projeto) => projeto.toJson()).toList();
    return _json(200, resposta);
  });

  router.get('/projetos/<id>', (Request request, String id) {
    final projetoId = _parseId(id);
    if (projetoId == null) {
      return _erro(400, 'ID do projeto inválido.');
    }

    final projeto = _encontrarProjetoPorId(projetos, projetoId);
    if (projeto == null) {
      return _erro(404, 'Projeto não encontrado.');
    }

    return _json(200, projeto.toJson());
  });

  router.post('/projetos', (Request request) async {
    final body = await _lerJson(request);
    if (body == null) {
      return _erro(400, 'Body inválido ou ausente.');
    }

    final nome = _texto(body['nome']);
    final descricao = _texto(body['descricao']);

    if (nome == null || descricao == null) {
      return _erro(400, 'Nome e descrição são obrigatórios.');
    }

    final novoProjeto = Projeto(
      id: _gerarNovoIdProjeto(projetos),
      nome: nome,
      descricao: descricao,
    );

    projetos.add(novoProjeto);
    return _json(201, novoProjeto.toJson());
  });

  router.put('/projetos/<id>', (Request request, String id) async {
    final projetoId = _parseId(id);
    if (projetoId == null) {
      return _erro(400, 'ID do projeto inválido.');
    }

    final indice = projetos.indexWhere((p) => p.id == projetoId);
    if (indice == -1) {
      return _erro(404, 'Projeto não encontrado.');
    }

    final body = await _lerJson(request);
    if (body == null) {
      return _erro(400, 'Body inválido ou ausente.');
    }

    final nome = _texto(body['nome']);
    final descricao = _texto(body['descricao']);

    if (nome == null || descricao == null) {
      return _erro(400, 'Nome e descrição são obrigatórios.');
    }

    final projetoAtualizado = projetos[indice].copyWith(
      nome: nome,
      descricao: descricao,
    );

    projetos[indice] = projetoAtualizado;
    return _json(200, projetoAtualizado.toJson());
  });

  router.all('/projetos/<id>', (Request request, String id) {
    if (request.method != 'DELETE') {
      return Response.notFound('Route not found');
    }

    final projetoId = _parseId(id);
    if (projetoId == null) {
      return _erro(400, 'ID do projeto inválido.');
    }

    final indice = projetos.indexWhere((p) => p.id == projetoId);
    if (indice == -1) {
      return _erro(404, 'Projeto não encontrado.');
    }

    projetos.removeAt(indice);
    tarefas.removeWhere((tarefa) => tarefa.projetoId == projetoId);

    return Response(
      204,
      headers: _headersJson,
    );
  });

  return router;
}

Projeto? _encontrarProjetoPorId(List<Projeto> projetos, int id) {
  try {
    return projetos.firstWhere((projeto) => projeto.id == id);
  } catch (_) {
    return null;
  }
}

int _gerarNovoIdProjeto(List<Projeto> projetos) {
  if (projetos.isEmpty) return 1;
  final maiorId = projetos.map((p) => p.id).reduce((a, b) => a > b ? a : b);
  return maiorId + 1;
}

int? _parseId(String valor) => int.tryParse(valor);

String? _texto(dynamic valor) {
  final texto = valor?.toString().trim();
  if (texto == null || texto.isEmpty) return null;
  return texto;
}

Future<Map<String, dynamic>?> _lerJson(Request request) async {
  try {
    final body = await request.readAsString();
    if (body.trim().isEmpty) return null;

    final json = jsonDecode(body);
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);

    return null;
  } catch (_) {
    return null;
  }
}

Response _erro(int status, String mensagem) {
  return _json(status, {'erro': mensagem});
}

Response _json(int status, Object body) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: _headersJson,
  );
}

const Map<String, String> _headersJson = {
  'Content-Type': 'application/json',
};