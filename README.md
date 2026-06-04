# Migration — desafioTecnico

## Posição na Arquitetura

```
Frontend → BFF → Backend → PostgreSQL
    ↑
[Este projeto orquestra tudo localmente e gerencia o schema do banco]
```

Este é o ponto de entrada para rodar a aplicação localmente. Ele contém o `docker-compose.yml` que sobe todos os serviços.

O schema do banco é gerenciado pelo **ORM (Hibernate)** com `ddl-auto: update` — o próprio backend cria e atualiza as tabelas automaticamente ao subir.

**Para rodar a aplicação localmente, comece sempre por aqui.**

## Hospedagem em Produção

| Serviço | Plataforma |
|---|---|
| Backend | Railway |
| BFF | Railway |
| Frontend | Cloudflare Pages |
| PostgreSQL | Railway |

## Segurança — Variáveis Obrigatórias em Produção

Além das variáveis do banco, os segredos JWT precisam ser configurados:

| Variável | Onde configurar | Descrição |
|---|---|---|
| `JWT_SECRET` | BFF | Assina os tokens de usuário (mín. 32 chars) |
| `SERVICE_TOKEN_SECRET` | BFF **e** Backend | Compartilhado — autentica o BFF no Backend (mín. 32 chars) |

> Os valores padrão (`changeme-...`) são apenas para desenvolvimento local. **Nunca use em produção.**

---

Este repositório centraliza as **migrations do banco de dados** e o **`docker-compose.yml`** para rodar todo o projeto localmente com um único comando.

---

## Repositórios do projeto

| Repositório | Conteúdo |
|-------------|----------|
| `Case-Tecnico` ← **este** | Migrations (Flyway) + docker-compose |
| `case-tecnico-app` | Backend Java (Clean Architecture + CQRS) |
| `case-tecnico-bff` | BFF Java (proxy + CORS + CEP) |
| `case-tecnico-frontend` | Frontend React + Vite |

---

## Estrutura de pastas esperada

Todos os repositórios devem estar **lado a lado na mesma pasta**:

```
GITHUB/
├── Case-Tecnico/           ← rodar docker compose aqui
│   ├── migrations/
│   ├── docker-compose.yml
│   ├── .env
│   └── README.md
├── case-tecnico-app/
│   └── backend/
├── case-tecnico-bff/
└── case-tecnico-frontend/
```

Se seus repos estiverem em outro caminho, edite o `context` de cada serviço no `docker-compose.yml`.

---

## Pré-requisitos

- Docker + Docker Compose
- Git

---

## Como rodar

**1. Clone todos os repositórios lado a lado:**

```bash
git clone https://github.com/LucasAmorimDosSantosSansiverinato/Case-Tecnico.git
git clone https://github.com/LucasAmorimDosSantosSansiverinato/case-tecnico-app.git
git clone https://github.com/LucasAmorimDosSantosSansiverinato/case-tecnico-bff.git
git clone https://github.com/LucasAmorimDosSantosSansiverinato/case-tecnico-frontend.git
```

**2. Crie o `.env` a partir do exemplo:**

```bash
cd Case-Tecnico
cp .env.example .env
```

O `.env` padrão funciona sem nenhuma alteração para uso local.

**3. Suba tudo:**

```bash
docker compose up --build
```

Acesse em `http://localhost:5173`.

---

## Arquivo `.env`

Copie `.env.example` para `.env` e ajuste se necessário:

```env
# Banco de dados
POSTGRES_DB=desafiotecnico
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# Portas (altere se alguma porta já estiver em uso)
BACKEND_PORT=8080
BFF_PORT=3001
FRONTEND_PORT=5173
```

**Você só precisa alterar se:**
- Já tiver outra aplicação rodando nas portas padrão
- Quiser usar uma senha diferente para o banco local

---

## Como alterar os caminhos dos repositórios

Se os repositórios não estiverem lado a lado, edite o `docker-compose.yml`:

```yaml
backend:
  build:
    context: ../case-tecnico-app/backend   # ← ajuste este caminho

bff:
  build:
    context: ../case-tecnico-bff           # ← ajuste este caminho

frontend:
  build:
    context: ../case-tecnico-frontend      # ← ajuste este caminho
```

O caminho é **relativo** à pasta `Case-Tecnico/`.

---

## Ordem de inicialização

O Docker Compose sobe os serviços nesta ordem, respeitando dependências:

```
postgres → migrations → backend → bff → frontend
```

O backend só sobe após as migrations criarem a tabela `persons`.

---

## Comandos úteis

```bash
# Subir tudo (primeira vez ou após mudanças)
docker compose up --build

# Subir em background
docker compose up -d --build

# Ver logs em tempo real
docker compose logs -f

# Ver logs de um serviço específico
docker compose logs -f backend
docker compose logs -f bff

# Parar tudo
docker compose down

# Parar tudo e apagar o banco (recomeça do zero)
docker compose down -v
```

---

## Portas padrão

| Serviço    | Porta  | URL                           |
|------------|--------|-------------------------------|
| Frontend   | `5173` | http://localhost:5173         |
| BFF        | `3001` | http://localhost:3001         |
| Backend    | `8080` | http://localhost:8080         |
| PostgreSQL | `5432` | localhost:5432/desafiotecnico |

---

## Migrations

Os arquivos SQL ficam em `migrations/src/main/resources/db/migration/`:

| Arquivo | O que faz |
|---------|-----------|
| `V1__create_persons_table.sql` | Cria a tabela `persons` |
| `V2__seed_persons.sql` | Insere 10 registros de teste |

Para criar uma nova migration, adicione um arquivo seguindo o padrão:
```
V{número}__{descricao_com_underline}.sql
```
Exemplo: `V3__add_phone_column.sql`

---

## Documentação completa

Abra `docs/index.html` no browser para ver:
- Diagrama de arquitetura
- Endpoints da API
- Lógica de geração de login
- Schema do banco
