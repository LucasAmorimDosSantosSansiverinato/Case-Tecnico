# Case Técnico — Cadastro de Pessoas

Aplicação full-stack de cadastro de pessoas com geração automática de login.

---

## Estrutura do projeto

```
.
├── backend/       Java Spring Boot — Clean Architecture + CQRS
├── bff/           Java Spring Boot — Backend for Frontend
├── frontend/      React + Vite
├── migrations/    Flyway — migrations do banco de dados
├── docs/          Documentação em HTML
└── docker-compose.yml
```

---

## Ambientes

| Onde | O que roda |
|------|-----------|
| Cloudflare Pages | Frontend (React) |
| VM (produção) | Backend + BFF (Java) |
| Supabase | PostgreSQL (produção) |
| Docker Compose | Tudo local para desenvolvimento |

---

## Pré-requisitos

- Java 21+
- Maven 3.9+
- Node.js 20+
- Docker

---

## Rodar localmente

### Docker Compose — recomendado

Sobe o banco, roda as migrations e inicia backend e BFF automaticamente:

```bash
docker compose up --build
```

Frontend roda separado:

```bash
cd frontend
npm install
npm run dev
```

Acesse em `http://localhost:5173`.

---

### Manual (passo a passo)

**1. Banco de dados**

```bash
docker run -d --name desafio-postgres \
  -e POSTGRES_DB=desafiotecnico \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16
```

**2. Migrations** — deve rodar antes do backend

```bash
cd migrations
mvn flyway:migrate
```

**3. Backend**

```bash
cd backend
mvn clean package -DskipTests
java -jar desafioTecnico-webui/target/desafioTecnico-webui-1.0.0-SNAPSHOT.jar
```

Porta `8080`.

**4. BFF**

```bash
cd bff
mvn clean package -DskipTests
java -jar target/desafioTecnico-bff-1.0.0-SNAPSHOT.jar
```

Porta `3001`.

**5. Frontend**

```bash
cd frontend
npm install
npm run dev
```

Porta `5173`.

---

## Variáveis de ambiente

Todas têm valores padrão para rodar localmente sem configuração adicional.

| Projeto  | Variável            | Padrão local                                    |
|----------|---------------------|-------------------------------------------------|
| backend  | `DATABASE_URL`      | `jdbc:postgresql://localhost:5432/desafiotecnico` |
| backend  | `DATABASE_USERNAME` | `postgres`                                      |
| backend  | `DATABASE_PASSWORD` | `postgres`                                      |
| backend  | `BFF_ORIGIN`        | `http://localhost:3001`                         |
| bff      | `BACKEND_URL`       | `http://localhost:8080`                         |
| bff      | `FRONTEND_ORIGIN`   | `http://localhost:5173`                         |
| frontend | `VITE_BFF_URL`      | `http://localhost:3001`                         |

---

## CI/CD — GitHub Actions

Push na branch `main` dispara o deploy automaticamente para cada serviço alterado.

| Workflow | Dispara quando muda | Deploy |
|----------|--------------------|----|
| `backend.yml` | `backend/**` | JAR → VM via SSH |
| `bff.yml` | `bff/**` | JAR → VM via SSH |
| `frontend.yml` | `frontend/**` | dist → Cloudflare Pages |
| `db-migration.yml` | `migrations/**` | Flyway → Supabase |

### Secrets necessários no repositório

Configure em **Settings → Secrets and variables → Actions**:

| Secret | Onde pegar |
|--------|-----------|
| `VM_HOST` | IP público da VM |
| `VM_USER` | Usuário SSH da VM (ex: `ubuntu`) |
| `VM_SSH_KEY` | Chave privada SSH para acessar a VM |
| `SUPABASE_DATABASE_URL` | Supabase → Connect → JDBC URL |
| `SUPABASE_DB_USERNAME` | Supabase → Connect → usuário |
| `SUPABASE_DB_PASSWORD` | Supabase → Connect → senha |
| `VITE_BFF_URL` | URL pública do BFF na VM (ex: `http://IP:3001`) |
| `CLOUDFLARE_API_TOKEN` | Cloudflare → My Profile → API Tokens |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare → lado direito da home |

### Subir o código pela primeira vez

```bash
git init
git add .
git commit -m "feat: initial project setup"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/case-tecnico.git
git push -u origin main
```

---

## Portas

| Serviço    | Porta  |
|------------|--------|
| Frontend   | `5173` |
| BFF        | `3001` |
| Backend    | `8080` |
| PostgreSQL | `5432` |

---

## Documentação completa

Abra `docs/index.html` no browser para ver diagrama de arquitetura, endpoints, lógica do login e schema do banco.

---

## Lógica do login

- Exatamente **7 caracteres**
- Apenas **letras minúsculas** (a–z), sem números e sem espaços
- **Único** por pessoa
- Gerado a partir do **nome completo**

**Estratégia:** prefixos do primeiro nome combinados com prefixos dos sobrenomes em diferentes proporções. Exemplo: `Maria Silva Souza` → `mariasi`.

---

## Documento (CPF)

Formato **CPF** — 11 dígitos com validação dos dígitos verificadores.
Aceita `529.982.247-25` ou `52998224725`.
