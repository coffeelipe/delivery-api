# Backlog do Projeto - Delivery API

Este documento apresenta o backlog de desenvolvimento seguindo a abordagem TDD (Test-Driven Development) adotada no projeto.

---

## Fase 1: Configuração Inicial e Infraestrutura

### 1.1 Setup do Ambiente Rails
**Descrição**: Inicializar projeto Rails API-only com configurações básicas
**Critérios de Aceitação**:
- Projeto Rails 8.1.2 criado em modo API
- Gemfile configurado com dependências essenciais (puma, sqlite3, rack-cors)
- Estrutura de diretórios Rails configurada
- Arquivo de configuração do banco de dados criado

### 1.2 Configuração Docker - Backend
**Descrição**: Criar Dockerfile e configurações para containerização da API
**Critérios de Aceitação**:
- Dockerfile criado na pasta API
- Script docker-entrypoint.sh configurado para inicialização
- Imagem pode ser buildada sem erros
- Container executa rails server corretamente

### 1.3 Configuração RSpec
**Descrição**: Instalar e configurar framework de testes RSpec
**Critérios de Aceitação**:
- Gems rspec-rails, factory_bot_rails e faker instaladas
- Arquivos rails_helper.rb e spec_helper.rb configurados
- Diretório spec/ criado com estrutura adequada
- Comando `bundle exec rspec` executa sem erros

---

## Fase 2: Desenvolvimento Backend com TDD

### 2.1 Model Order - Setup e Testes
**Descrição**: Criar model Order com validações e testes unitários
**Critérios de Aceitação**:
- Migration create_orders criada com campos id (string), store_id e order (json)
- Testes escritos em spec/models/order_spec.rb
- Validações de presença para id, store_id e details implementadas
- Geração automática de UUID para novos pedidos
- Todos os testes do model passando

*Train of thought - Por que começar pelo model?**: Começo pelo model porque ele define a estrutura de dados base. Com TDD, os testes me forçam a pensar no schema e validações antes de qualquer lógica de negócio.

### 2.2 Migration e Refatoração do Schema
**Descrição**: Renomear coluna 'order' para 'details' no banco de dados
**Critérios de Aceitação**:
- Migration de renomeação criada (rename_order_to_details_in_orders.rb)
- Schema atualizado corretamente
- Model Order usa campo 'details' em vez de 'order'
- Testes atualizados e passando

**Train of thought - Por que refatorar o schema agora?**: Refatorar o schema cedo evita acoplamento com um nome de campo inadequado. O nome order era confuso, pois o model já se chama Order. Detalhes do pedido fazem mais sentido em 'details'. Fazer isso antes de implementar lógica complexa evita dores de cabeça futuras.
Decidi utilizar sqlite ao invés do json cru mesmo para este pequeno code challange, pois isso me permite aproveitar as funcionalidades do ActiveRecord, como validações, callbacks e associações, além de facilitar a persistência e manipulação dos dados. O uso de um banco de dados relacional também torna o projeto mais realista e alinhado com práticas comuns de desenvolvimento, mesmo que seja um desafio pequeno.

### 2.3 Integração com pedidos.json
**Descrição**: Implementar seed para popular banco com dados do pedidos.json
**Critérios de Aceitação**:
- Arquivo pedidos.json colocado em db/seeds/
- Lógica de seed implementada em db/seeds.rb
- Comando `rails db:seed` popula banco com dados do JSON
- Estrutura de dados mantida (order_id, store_id, order)
- Dados persistidos no SQLite corretamente

**Train of thought - Pedidos.json**: Embora eu utilize SQLite para persistência, o desafio menciona o uso do arquivo pedidos.json como fonte de dados e diz que um novo arquivo não deve ser criado. Então eu adiciono o pedidos.json ao diretório db/seeds/ e implemento a lógica de seed para popular o banco com os dados pré-existentes.

### 2.4 Service StatusAppender - Implementação e Testes
**Descrição**: Criar serviço para adicionar novos status aos pedidos
**Critérios de Aceitação**:
- Testes escritos em spec/services/status_appender_spec.rb
- Classe StatusAppender criada em app/services/
- Método append adiciona status ao array de statuses do pedido
- Atualiza last_status_name automaticamente
- Todos os testes do serviço passando

**Train of thought - Por que criar um serviço para isso?**: A lógica por trás desse serviço se dá na maneira como o `pedidos.json` é originalmente estruturado, ele possui uma chave last_status_name que contém o nome do status atual do pedido, mas também um array de statuses que contém o histórico completo. Para manter essa estrutura e garantir que o status atual seja sempre atualizado corretamente, crio um serviço dedicado para lidar com essa lógica.

### 2.5 Service StateMachine - Implementação e Testes
**Descrição**: Implementar máquina de estados para transições de status
**Critérios de Aceitação**:
- Testes escritos em spec/services/state_machine_spec.rb
- Classe StateMachine criada com hash TRANSITIONS
- Método valid_transition? valida transições permitidas
- Método terminal_state? identifica estados finais
- Método cancel_order implementa lógica de cancelamento
- Método transition_order implementa progressão de estados
- Regras de negócio respeitadas:
  - RECEIVED → CONFIRMED → DISPATCHED → DELIVERED
  - Cancelamento permitido em RECEIVED, CONFIRMED, DISPATCHED
  - Estados terminais: DELIVERED, CANCELED
- Todos os testes da state machine passando

### 2.6 Model Order - Callbacks e Status Inicial
**Descrição**: Adicionar callbacks para inicialização de pedidos
**Critérios de Aceitação**:
- Callback before_validation gera UUID se necessário
- Callback before_create inicializa campo details com order_id e array statuses
- Callback after_create define status inicial como RECEIVED
- Testes cobrem comportamento dos callbacks
- Status RECEIVED adicionado automaticamente em novos pedidos

**Train of thought - callbacks e inicialização **: Era preciso trabalhar tanto com novos pedidos mas principalmente com os pedidos já existentes no `pedidos.json`, afim de facilitar a lógica de transição de estados, defini o status inicial como RECEIVED durante a criação do pedido, isso garante que todos os pedidos, sejam eles novos ou provenientes do JSON, tenham um status inicial consistente. Os callbacks permitem automatizar essa lógica, garantindo que o status seja definido corretamente sem depender de chamadas manuais adicionais.

### 2.7 Controller Orders - CRUD e Testes
**Descrição**: Implementar ações CRUD no OrdersController
**Critérios de Aceitação**:
- Testes de request escritos em spec/requests/orders_spec.rb
- Ação index retorna lista de pedidos em JSON
- Ação show retorna pedido específico por ID
- Ação create cria novo pedido com status RECEIVED
- Ação destroy remove pedido do banco
- Testes cobrem casos de sucesso e erro
- Todos os testes de request passando

### 2.8 Controller Orders - Endpoint de Transição de Status
**Descrição**: Implementar endpoint para mudança de status do pedido
**Critérios de Aceitação**:
- Ação append_status criada no OrdersController
- Endpoint aceita parâmetro :cancel para cancelamento
- Integração com StateMachine para transições
- Endpoint não permite mudanças em estados terminais
- Testes cobrem progressão e cancelamento
- Resposta JSON retorna pedido atualizado

### 2.9 Routes - Configuração de Rotas RESTful
**Descrição**: Configurar rotas da API seguindo padrão REST
**Critérios de Aceitação**:
- Rotas resources :orders configuradas para index, show, create, destroy
- Rota member patch 'status' configurada para append_status
- Estrutura RESTful mantida
- Documentação de rotas clara

as rotas e suas ações correspondentes:
- GET /orders → index
- GET /orders/:id → show
- POST /orders → create
- DELETE /orders/:id → destroy
- PATCH /orders/:id/status → append_status

Pode encontrá-los em: API/config/routes.rb e API/app/controllers/orders_controller.rb


### 2.10 CORS - Configuração para Frontend
**Descrição**: Configurar CORS para permitir requisições do frontend
**Critérios de Aceitação**:
- Gem rack-cors instalada
- CORS configurado em config/initializers/cors.rb
- Origem permitida para localhost:8080
- Headers necessários habilitados
- Métodos GET, POST, PATCH, DELETE permitidos

---

## Fase 3: Desenvolvimento Frontend Flutter

### 3.1 Setup Flutter Web
**Descrição**: Inicializar projeto Flutter com configurações web
**Critérios de Aceitação**:
- Projeto Flutter criado
- pubspec.yaml configurado com dependências (http, intl)
- Estrutura de diretórios criada (models, pages, services, widgets, utils)
- Arquivo main.dart com MaterialApp básico

### 3.2 Models - Order e Store
**Descrição**: Criar classes de modelo para dados da aplicação
**Critérios de Aceitação**:
- Model Order criado em lib/models/order.dart
- Model Store criado em lib/models/store.dart
- Métodos fromJson e toJson implementados
- Estrutura de dados alinhada com backend
- Enums ou constantes para status definidos

**Train of thought - Models**: Eu utilizei como base as lojas já existentes no `pedidos.json` para criar o model Store, possibilitando uma estrutura mais realista e alinhada com os dados que a API irá fornecer. E deixando a interface de criação de pedidos mais completa, permitindo que o usuário selecione a loja ao invés de ter um valor fixo. O model Order é criado para refletir a estrutura dos pedidos, incluindo os campos necessários para exibir as informações no frontend e interagir com a API.

### 3.3 Service - Integração com API
**Descrição**: Criar serviço para comunicação HTTP com backend
**Critérios de Aceitação**:
- OrdersService criado em lib/services/orders_service.dart
- Métodos implementados: fetchOrders, createOrder, deleteOrder, updateOrderStatus
- Tratamento de erros HTTP implementado
- URL da API configurável via variável de ambiente
- Respostas parseadas para models Order

### 3.4 Dashboard - Estrutura Principal
**Descrição**: Criar página principal com dashboard de pedidos
**Critérios de Aceitação**:
- HomePage criada em lib/pages/home_page.dart
- Layout responsivo com AppBar e corpo principal
- Estado gerenciado com StatefulWidget
- Carregamento inicial de pedidos da API
- Indicador de loading durante requisições
- Tratamento de erros de rede

**Train of thought - Dashboard**: A aplicação é centrada em um dashboard visual que organiza os pedidos por status. Escolhi então uma apresentação com estilo kanban, onde cada coluna representa um status (RECEIVED, CONFIRMED, DISPATCHED, DELIVERED, CANCELED) e os pedidos são exibidos como cards dentro dessas colunas. Acredito que essa estrutura facilita a visualização do fluxo dos pedidos e torna a interface mais intuitiva.

## Widgets (Componentes Reutilizáveis)
### 3.5 Widgets - Cards de Estatísticas
**Descrição**: Criar cards para exibir métricas do dashboard
**Critérios de Aceitação**:
- StatCard widget criado em lib/widgets/stat_card.dart
- Cards exibem total de pedidos por status
- Design Material com cores diferenciadas por status
- Layout responsivo para diferentes tamanhos de tela
- Animações suaves ao atualizar valores

### 3.6 Widgets - Cards de Pedidos
**Descrição**: Criar cards para exibir informações de cada pedido
**Critérios de Aceitação**:
- OrderCard widget criado em lib/widgets/order_card.dart
- Card exibe informações: ID, loja, status atual, timestamp
- Indicador visual de status com cores
- Botões de ação: avançar status, cancelar, excluir
- Interação ao clicar abre detalhes do pedido

### 3.7 Dialogs - Novo Pedido e Detalhes
**Descrição**: Implementar diálogos para criação e visualização de pedidos
**Critérios de Aceitação**:
- NewOrderDialog criado em lib/widgets/new_order_dialog.dart
- OrderDialog criado em lib/widgets/order_dialog.dart
- Formulário de criação com validação
- Exibição de histórico completo de status
- Ações confirmam antes de executar
- Feedback visual (SnackBar) após ações

### 3.8 Dashboard - Colunas por Status
**Descrição**: Organizar pedidos em colunas por status
**Critérios de Aceitação**:
- DashboardColumn widget criado em lib/widgets/dashboard_column.dart
- Layout de múltiplas colunas (RECEIVED, CONFIRMED, DISPATCHED, DELIVERED, CANCELED)
- Pedidos filtrados e agrupados por status
- Scroll independente em cada coluna
- Visual clean e organizado

### 3.9 Integração Completa - Operações CRUD
**Descrição**: Integrar todas as operações com backend
**Critérios de Aceitação**:
- Criação de pedido atualiza dashboard automaticamente
- Mudança de status move card para coluna correta
- Exclusão de pedido remove card do dashboard
- Polling ou refresh manual atualiza dados
- Estados terminais desabilitam ações indevidas
- Sincronização completa entre frontend e backend

### 3.10 Configuração Docker - Frontend
**Descrição**: Criar Dockerfile para build e servir frontend
**Critérios de Aceitação**:
- Dockerfile multi-stage criado na pasta frontend
- Build do Flutter web configurado
- Nginx configurado para servir aplicação
- Variável de ambiente API_URL configurável
- Imagem otimizada para produção

---

## Fase 4: Integração e Deploy

### 4.1 Docker Compose - Orquestração
**Descrição**: Configurar docker-compose para executar stack completo
**Critérios de Aceitação**:
- docker-compose.yml na raiz do projeto
- Serviços api e frontend configurados
- Volumes para persistência de dados (storage, tmp)
- Networks para comunicação entre containers
- Health checks implementados
- Variáveis de ambiente configuradas (SECRET_KEY_BASE, API_URL)
- Dependências entre serviços (frontend depende de api)

### 4.2 Persistência de Dados
**Descrição**: Garantir persistência do banco SQLite entre restarts
**Critérios de Aceitação**:
- Volume api_storage montado em /app/storage
- Banco de dados persiste após parar containers
- Seeds executados apenas na primeira inicialização
- Dados de desenvolvimento/produção separados

### 4.3 Testes de Integração
**Descrição**: Validar funcionamento completo da aplicação
**Critérios de Aceitação**:
- API responde corretamente em http://localhost:3000
- Frontend acessível em http://localhost:8080
- Comunicação entre frontend e backend funcional
- Operações CRUD funcionam end-to-end
- Máquina de estados respeitada em todas as transições

### 4.4 Documentação - README
**Descrição**: Criar documentação completa do projeto
**Critérios de Aceitação**:
- README.md com visão geral do projeto
- Justificativa da escolha de tecnologias
- Arquitetura e estrutura do projeto explicadas
- Instruções para execução com Docker
- Seção de melhorias futuras

### 4.5 Documentação - DEPLOYMENT
**Descrição**: Criar guia detalhado de deploy local
**Critérios de Aceitação**:
- DEPLOYMENT.md com instruções passo a passo
- Pré-requisitos listados (Docker, Docker Compose)
- Comandos para build e execução documentados
- Troubleshooting de problemas comuns
- Instruções para popular banco com dados iniciais

---
