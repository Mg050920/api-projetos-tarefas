import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:backend/models/projeto.dart';
import 'package:backend/models/tarefa.dart';

Router tarefaRoutes(List<Tarefa> tarefas, List<Projeto> projetos) {
  final router = Router();

  router.get('/tarefas', (Request request) {
    final resposta = tarefas.map((tarefa) => tarefa.toJson()).toList();
    return _json(200, resposta);
  });

  router.get('/tarefas/<id>', (Request request, String id) {
    final tarefaId = _parseId(id);
    if (tarefaId == null) {
      return _erro(400, 'ID da tarefa inválido.');
    }

    final tarefa = _encontrarTarefaPorId(tarefas, tarefaId);
    if (tarefa == null) {
      return _erro(404, 'Tarefa não encontrada.');
    }

    return _json(200, tarefa.toJson());
  });

  router.get('/projetos/<id>/tarefas', (Request request, String id) {
    final projetoId = _parseId(id);
    if (projetoId == null) {
      return _erro(400, 'ID do projeto inválido.');
    }

    final projetoExiste = projetos.any((projeto) => projeto.id == projetoId);
    if (!projetoExiste) {
      return _erro(404, 'Projeto não encontrado.');
    }

    final tarefasDoProjeto = tarefas
        .where((tarefa) => tarefa.projetoId == projetoId)
        .map((tarefa) => tarefa.toJson())
        .toList();

    return _json(200, tarefasDoProjeto);
  });

  router.post('/tarefas', (Request request) async {
    final body = await _lerJson(request);
    if (body == null) {
      return _erro(400, 'Body inválido ou ausente.');
    }

    final titulo = _texto(body['titulo']);
    final status = _texto(body['status']);
    final projetoId = _parseId(body['projetoId']?.toString() ?? '');

    if (titulo == null || status == null || projetoId == null) {
      return _erro(400, 'Título, status e projetoId são obrigatórios.');
    }

    final projetoExiste = projetos.any((projeto) => projeto.id == projetoId);
    if (!projetoExiste) {
      return _erro(404, 'Projeto não encontrado.');
    }

    final novaTarefa = Tarefa(
      id: _gerarNovoIdTarefa(tarefas),
      titulo: titulo,
      status: status,
      projetoId: projetoId,
    );

    tarefas.add(novaTarefa);
    return _json(201, novaTarefa.toJson());
  });

  router.put('/tarefas/<id>', (Request request, String id) async {
    final tarefaId = _parseId(id);
    if (tarefaId == null) {
      return _erro(400, 'ID da tarefa inválido.');
    }

    final indice = tarefas.indexWhere((t) => t.id == tarefaId);
    if (indice == -1) {
      return _erro(404, 'Tarefa não encontrada.');
    }

    final body = await _lerJson(request);
    if (body == null) {
      return _erro(400, 'Body inválido ou ausente.');
    }

    final titulo = _texto(body['titulo']);
    final status = _texto(body['status']);
    final projetoId = _parseId(body['projetoId']?.toString() ?? '');

    if (titulo == null || status == null || projetoId == null) {
      return _erro(400, 'Título, status e projetoId são obrigatórios.');
    }

    final projetoExiste = projetos.any((projeto) => projeto.id == projetoId);
    if (!projetoExiste) {
      return _erro(404, 'Projeto não encontrado.');
    }

    final tarefaAtualizada = tarefas[indice].copyWith(
      titulo: titulo,
      status: status,
      projetoId: projetoId,
    );

    tarefas[indice] = tarefaAtualizada;
    return _json(200, tarefaAtualizada.toJson());
  });

  router.all('/tarefas/<id>', (Request request, String id) {
    if (request.method != 'DELETE') {
      return Response.notFound('Route not found');
    }

    final tarefaId = _parseId(id);
    if (tarefaId == null) {
      return _erro(400, 'ID da tarefa inválido.');
    }

    final indice = tarefas.indexWhere((t) => t.id == tarefaId);
    if (indice == -1) {
      return _erro(404, 'Tarefa não encontrada.');
    }

    tarefas.removeAt(indice);

    return Response(
      204,
      headers: _headersJson,
    );
  });

  return router;
}

Tarefa? _encontrarTarefaPorId(List<Tarefa> tarefas, int id) {
  try {
    return tarefas.firstWhere((tarefa) => tarefa.id == id);
  } catch (_) {
    return null;
  }
}

int _gerarNovoIdTarefa(List<Tarefa> tarefas) {
  if (tarefas.isEmpty) return 1;
  final maiorId = tarefas.map((t) => t.id).reduce((a, b) => a > b ? a : b);
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