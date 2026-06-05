# Case Técnico — Cadastro de Pessoas

## Arquitetura

```
Frontend → BFF → Backend → PostgreSQL
```

Ponto de entrada para rodar tudo localmente via Docker Compose.

---

## Repositórios

| Repositório | Conteúdo |
|---|---|
| `Case-Tecnico` ← **este** | Docker Compose + Migrations |
| `case-tecnico-app` | Backend Java |
| `case-tecnico-bff` | BFF Java |
| `case-tecnico-frontend` | Frontend React + Vite |

---

## Produção

| Serviço | Plataforma | Por quê |
|---|---|---|
| Backend + BFF | Render | Free tier |
| Frontend | Cloudflare Pages | Free tier + CDN |
| PostgreSQL | Supabase | Free tier |

**Render dorme após 15 min de inatividade.** Para evitar isso, configurei um monitor no UptimeRobot que bate no health check a cada 5 minutos.

---

## Decisões

**BFF separado:** isola o Backend da internet, centraliza CORS e autenticação de usuário. No futuro facilita criar um backoffice sem duplicar lógica — é só um novo BFF consumindo o mesmo Backend.

**JWT duplo:** token de usuário (8h) para o Frontend autenticar rotas no BFF + service token (30s) que o BFF assina em cada chamada ao Backend. O Backend fica inacessível diretamente mesmo que alguém saiba a URL.

**Clerk (não usado):** facilitaria muito o auth, mas não estava nas tecnologias da vaga. Implementei JWT do zero.

**Supabase / Render / Cloudflare:** free tier em todos, sem cartão de crédito.

---

## Como rodar localmente

```bash
git clone https://github.com/LucasAmorimDosSantosSansiverinato/Case-Tecnico.git
git clone https://github.com/LucasAmorimDosSantosSansiverinato/case-tecnico-app.git
git clone https://github.com/LucasAmorimDosSantosSansiverinato/case-tecnico-bff.git
git clone https://github.com/LucasAmorimDosSantosSansiverinato/case-tecnico-frontend.git

cd Case-Tecnico
cp .env.example .env
docker compose up --build
```

Acesse em `http://localhost:5173`.

---

## Portas padrão

| Serviço | Porta |
|---|---|
| Frontend | 5173 |
| BFF | 3001 |
| Backend | 8080 |
| PostgreSQL | 5432 |

---

## Segurança — variáveis obrigatórias em produção

| Variável | Onde | Descrição |
|---|---|---|
| `JWT_SECRET` | BFF | Assina tokens de usuário (mín. 32 chars) |
| `SERVICE_TOKEN_SECRET` | BFF + Backend | Autentica BFF → Backend (mín. 32 chars) |
