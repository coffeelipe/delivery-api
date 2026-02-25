# Guia de Deploy Local - Delivery API

Este documento fornece instruções detalhadas para executar o projeto Delivery API localmente utilizando Docker.

---

## Pré-requisitos

Antes de iniciar, certifique-se de ter os seguintes programas instalados:

### Docker
- **Docker Engine** versão 20.10 ou superior
- **Docker Compose** versão 2.0 ou superior

#### Verificar Instalação

```bash
docker --version
docker compose version
```

Saída esperada:
```
Docker version 24.0.0 ou superior
Docker Compose version v2.0.0 ou superior
```

---

## Método 1: Deploy com Docker Compose (Recomendado)

Este é o método mais simples e rápido para executar o projeto completo.

### Passo 1: Clonar o Repositório

```bash
git clone git@github.com:coffeelipe/delivery-api.git
cd delivery-api
```

### Passo 2: Configurar Variáveis de Ambiente (Opcional)

Por padrão, o projeto já vem configurado para funcionar localmente. Se desejar customizar:

```bash
# Criar arquivo .env na raiz do projeto
cp .env.example .env  # Se existir, caso contrário crie manualmente
```

Edite o arquivo `.env`:
```bash
# Chave secreta para Rails (será gerada automaticamente se omitida)
SECRET_KEY_BASE=sua_chave_secreta_aqui

# URL da API (não precisa alterar para uso local)
API_URL=http://localhost:3000
```

Para gerar uma SECRET_KEY_BASE:
```bash
openssl rand -hex 64
```

### Passo 3: Iniciar os Serviços

```bash
docker compose up --build
```

Este comando irá:
1. Fazer o build das imagens Docker (backend Rails e frontend Flutter)
2. Criar os containers necessários
3. Inicializar o banco de dados SQLite
4. Executar as migrations
5. Popular o banco com dados iniciais (seeds do pedidos.json)
6. Iniciar os serviços

**Primeira execução**: O build pode levar alguns minutos (5-10 min) dependendo da sua conexão e hardware.

**Execuções subsequentes**: Serão muito mais rápidas (segundos) pois as imagens já estarão buildadas.

### Passo 4: Verificar Status dos Containers

Em outro terminal, verifique se os containers estão rodando:

```bash
docker compose ps
```

Saída esperada:
```
NAME                  STATUS              PORTS
delivery-api          Up (healthy)        0.0.0.0:3000->3000/tcp
delivery-frontend     Up                  0.0.0.0:8080->80/tcp
```

### Passo 5: Acessar a Aplicação

Aguarde a mensagem de que os serviços estão prontos. Então acesse:

- **Frontend (Interface Web)**: [http://localhost:8080](http://localhost:8080)
- **API (Backend)**: [http://localhost:3000](http://localhost:3000)

#### Testando a API

```bash
# Listar todos os pedidos
curl http://localhost:3000/orders

# Buscar pedido específico (use um ID retornado pelo comando anterior, alternativamente pela interface web slecione um pedido e clique no botão de copiar para clipboard ao lado do ID na tela de detalhes)
curl http://localhost:3000/orders/<ID_DO_PEDIDO>

# Health check
curl http://localhost:3000/up
```

### Passo 6: Visualizar Logs

Para acompanhar os logs dos serviços em tempo real:

```bash
# Logs de todos os serviços
docker compose logs -f

# Logs apenas do backend
docker compose logs -f api

# Logs apenas do frontend
docker compose logs -f frontend
```

### Passo 7: Parar e Limpar os Serviços

#### Parar containers (mantém dados)

```bash
# Parar sem remover containers
docker compose stop

# Parar e remover containers (mantém volumes/dados)
docker compose down
```

#### Limpeza completa (remove tudo)

```bash
# Parar e remover containers + volumes (APAGA O BANCO DE DADOS)
docker compose down -v

# Remover volumes específicos manualmente
docker volume rm delivery-api_api_storage delivery-api_api_tmp

# Remover também as imagens buildadas
docker compose down --rmi all -v
```

**Atenção**: O comando `docker compose down -v` apaga permanentemente o banco de dados SQLite e todos os pedidos criados. Use apenas se quiser começar do zero.

---

## Método 2: Build e Execução Manual dos Containers

Para mais controle sobre cada serviço individualmente:

### Backend (API Rails)

```bash
# Build da imagem
docker build -t delivery-api:latest ./API

# Executar container
docker run -d \
  --name delivery-api \
  -p 3000:3000 \
  -v $(pwd)/API/storage:/app/storage \
  -v $(pwd)/API/tmp:/app/tmp \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=$(openssl rand -hex 64) \
  delivery-api:latest

# Verificar logs
docker logs -f delivery-api
```

### Frontend (Flutter Web)

```bash
# Build da imagem
docker build -t delivery-frontend:latest ./frontend

# Executar container
docker run -d \
  --name delivery-frontend \
  -p 8080:80 \
  delivery-frontend:latest

# Verificar logs
docker logs -f delivery-frontend
```

---

## Comandos Úteis

### Gerenciamento de Containers

```bash
# Reiniciar todos os serviços
docker compose restart

# Reiniciar apenas um serviço
docker compose restart api

# Executar comando dentro do container da API
docker compose exec api rails console
docker compose exec api bash

# Executar migrations manualmente
docker compose exec api rails db:migrate

# Recarregar seeds
docker compose exec api rails db:seed
```

### Limpeza e Manutenção

```bash
# Remover todos os containers parados
docker container prune

# Remover todas as imagens não utilizadas
docker image prune

# Limpar tudo (cuidado!)
docker system prune -a --volumes
```

### Rebuild Forçado

Se fizer alterações no código e precisar rebuildar:

```bash
# Rebuild completo ignorando cache
docker compose build --no-cache

# Rebuild e restart
docker compose up --build --force-recreate
```

---

## Dados Iniciais (Seeds)

O projeto vem com dados de exemplo no arquivo `API/db/seeds/pedidos.json`. Esses dados são automaticamente carregados na primeira execução.

### Popular Banco Manualmente

Se precisar repopular o banco de dados:

```bash
# Resetar banco completamente (cuidado: apaga tudo!)
docker compose exec api rails db:reset

# Apenas executar seeds
docker compose exec api rails db:seed
```

### Adicionar Novos Dados Iniciais

1. Edite o arquivo `API/db/seeds/pedidos.json`
2. Adicione novos registros seguindo a estrutura existente
3. Execute:
```bash
docker compose exec api rails db:seed
```

---

## Troubleshooting

### Problema: Porta já em uso

**Sintoma**: Erro `bind: address already in use`

**Solução**:
```bash
# Descobrir qual processo está usando a porta
sudo lsof -i :3000  # ou :8080 para o frontend

# Parar o processo se necessário
kill -9 <PID>

# Ou alterar a porta no docker-compose.yml
```

### Problema: Container não inicia

**Sintoma**: Container está em status "Exited" ou "Restarting"

**Solução**:
```bash
# Ver logs detalhados
docker compose logs api

# Verificar health check
docker inspect delivery-api | grep -A 10 Health

# Reconstruir do zero
docker compose down -v
docker compose up --build
```

### Problema: Secret Key Base não configurada

**Sintoma**: Erro `ArgumentError: Missing required 'secret_key_base'`

**Solução**:
```bash
# Gerar uma nova chave
openssl rand -hex 64

# Definir no docker-compose.yml ou criar arquivo .env
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" > .env
docker compose up --build
```

### Problema: Permissões no Linux

**Sintoma**: Erros de permissão ao criar volumes ou arquivos

**Solução**:
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Ou executar com sudo (não recomendado)
sudo docker compose up --build
```

### Problema: CORS bloqueando requisições

**Sintoma**: Erro de CORS no console do navegador

**Solução**:

1. Verifique configuração em `API/config/initializers/cors.rb`
2. Certifique-se de que a origem correta está permitida:

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:8080', '127.0.0.1:8080'
    resource '*', headers: :any, methods: [:get, :post, :patch, :delete, :options]
  end
end
```

3. Rebuild:
```bash
docker compose up --build
```

### Problema: Frontend não conecta à API

**Sintoma**: Pedidos não carregam, erros HTTP no console

**Solução**:

1. Verifique se a API está acessível:
```bash
curl http://localhost:3000/orders
```

2. Verifique configuração da URL no frontend (deve usar `http://localhost:3000`)

3. Verifique logs do backend:
```bash
docker compose logs -f api
```

### Problema: Banco de dados corrompido

**Sintoma**: Erros SQLite ao fazer queries

**Solução**:
```bash
# Parar containers
docker compose down

# Remover volumes (apaga dados)
docker volume rm delivery-api_api_storage delivery-api_api_tmp

# Reiniciar do zero
docker compose up --build
```

---

## Verificação Pós-Deploy

Execute os seguintes testes para garantir que tudo está funcionando:

### 1. Health Check da API

```bash
curl -f http://localhost:3000/up
```

Resposta esperada: Status 200 OK

### 2. Listar Pedidos

```bash
curl http://localhost:3000/orders | jq
```

Deve retornar array JSON com pedidos do seed.

### 3. Criar Novo Pedido

```bash
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{
    "store_id": "STORE_TEST",
    "details": {
      "customer": "Teste Deploy",
      "items": ["Item 1", "Item 2"]
    }
  }' | jq
```

Deve retornar o pedido criado com status RECEIVED.

### 4. Frontend Carrega

Acesse http://localhost:8080 e verifique:
- Dashboard exibe cards de pedidos
- Estatísticas mostram números corretos
- Botão "Novo Pedido" abre diálogo
- Cards respondem a cliques

### 5. Executar Testes

```bash
# Backend
docker compose exec api bundle exec rspec

# Verificar cobertura
docker compose exec api bundle exec rspec --format documentation
```

---

## Próximos Passos

Após o deploy local bem-sucedido:

1. **Explorar a Aplicação**: Crie, edite e avance pedidos pelo dashboard
2. **Testar a API**: Use Postman, Insomnia ou curl para testar endpoints
3. **Revisar Código**: Explore a estrutura do projeto
4. **Executar Testes**: Rode a suite de testes RSpec
5. **Consultar Backlog**: Veja [BACKLOG.md](BACKLOG.md) para entender o processo de desenvolvimento

---

## Suporte

Para problemas não listados aqui:

1. Verifique os logs: `docker compose logs -f`
2. Consulte documentação oficial do Docker
3. Revise as configurações nos Dockerfiles e docker-compose.yml

---

## Referências

- [Documentação Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Flutter Documentation](https://docs.flutter.dev/)
