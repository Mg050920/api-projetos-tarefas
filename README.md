# API CRUD em Dart

Este projeto é uma API simples desenvolvida em Dart para praticar os conceitos de CRUD: criar, listar, atualizar e remover registros.

## Tecnologias utilizadas

- Dart
- Shelf
- Servidor HTTP
- JSON
- Postman

## Funcionalidades

- Criar um registro
- Listar registros
- Atualizar um registro
- Remover um registro
- Relacionar uma entidade pai com uma entidade filho

## Como executar

1. Instalar as dependências:

```bash
dart pub get
```

2. Rodar o servidor:

```bash
dart run bin/server.dart
```

3. Testar a API usando o Postman.

A API roda em:

```text
http://localhost:8080
```

## Postman

A collection utilizada para testar e documentar a API está disponível na pasta:

```text
postman/Projeto API.postman_collection.json
```

Para testar, basta importar esse arquivo no Postman, iniciar a API e executar as requisições.
