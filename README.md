# Delivery API

Sistema completo de gerenciamento de pedidos de delivery com backend em Rails e frontend em Flutter Web.

---

## Sobre o Projeto

Este projeto foi desenvolvido como resposta a um desafio técnico para vaga de desenvolvedor junior. O objetivo é criar uma API RESTful para gerenciar pedidos de delivery, incluindo um sistema de máquina de estados para controlar o ciclo de vida dos pedidos, acompanhada de uma interface visual para visualização e manipulação dos dados.

---

## Execução rápida com Docker:

```bash
# 1. Clone o repositório
git clone https://github.com/coffeelipe/delivery-api.git
cd delivery-api

# 2. Inicie os containers
docker compose up --build
```

Aguarde o build das imagens e a inicialização dos serviços. Quando estiver pronto:
- **Frontend**: http://localhost:8080
- **API**: http://localhost:3000
- para detalhes completos do processo, consulte [DEPLOYMENT.md](DEPLOYMENT.md).

Nenhuma configuração adicional é necessária. O arquivo .env só é necessário caso queira sobrescrever as variáveis de ambiente padrão (ex: SECRET_KEY_BASE, API_PORT).

## Tecnologias Utilizadas

### Backend
- **Ruby on Rails 8.1.2** (modo API)
- **SQLite** (banco de dados)
- **Puma** (servidor web)
- **RSpec** (testes)
- **Factory Bot** e **Faker** (factories e dados fake para testes)

### Frontend
- **Flutter 3.11+** (framework web)
- **Dart** (linguagem)
- **HTTP package** (requisições à API)
- **Material Design** (design system)

### DevOps
- **Docker** e **Docker Compose** (containerização)
- **Nginx** (servidor web para frontend)

---

## Por que Rails?

Ruby on Rails foi escolhido pela sua natureza opinionated e convenções bem estabelecidas, o que possibilita desenvolvimento rápido e organizado. Para um desafio focado em CRUD RESTful, Rails oferece:

- **Convention over Configuration**: Estrutura padronizada que facilita manutenção
- **Active Record**: ORM poderoso que simplifica operações de banco de dados
- **Ecosystem maduro**: Gems robustas para praticamente qualquer necessidade
- **API mode**: Configuração otimizada para APIs sem overhead desnecessário
- **Facilidade para testes**: RSpec integrado com excelente suporte a TDD

Isso permitiu me focar na implementação da lógica de negócio (máquina de estados) em vez de configurações básicas.

---

## Por que Flutter?

Flutter foi escolhido por ser minha stack principal atual e pelos seguintes benefícios:

- **Cross-platform**: Mesmo codebase funciona em web, mobile (iOS/Android) e desktop (Windows/macOS/Linux)
- **Escalabilidade**: Facilita expansão futura para aplicativos móveis sem reescrever código
- **Performance**: Compilação para código nativo garante performance próxima de apps nativos
- **Hot Reload**: Desenvolvimento ágil com feedback visual imediato
- **Material Design**: Componentes prontos para UI consistente e moderna
- **Type-safe**: Dart é fortemente tipado, reduzindo erros em tempo de execução

---

## Funcionalidades

### API (Backend)
- Criação de pedidos com status inicial RECEIVED
- Listagem de todos os pedidos
- Consulta de pedido específico por ID
- Exclusão de pedidos
- Atualização de status seguindo máquina de estados
- Cancelamento de pedidos em estados permitidos
- Persistência em SQLite
- Seeds com dados iniciais do pedidos.json

### Máquina de Estados
A máquina de estados implementa as seguintes regras:

```
RECEIVED → CONFIRMED → DISPATCHED → DELIVERED
    ↓          ↓            ↓
         CANCELED
```

**Regras**:
- Novos pedidos iniciam como RECEIVED
- CONFIRMED não pode voltar para RECEIVED
- DISPATCHED não pode voltar para estados anteriores
- CANCELED é acessível de RECEIVED, CONFIRMED e DISPATCHED
- DELIVERED e CANCELED são estados terminais (não permitem transições)

### Frontend (Interface Web)
- Dashboard visual com cards de pedidos organizados por status
- Indicadores de métricas (total de pedidos por status)
- Criação de novos pedidos via formulário
- Preenchimento automático de endereço via CEP (integração com ViaCEP)
- Visualização de detalhes e histórico completo de status
- Botões de ação para avançar status ou cancelar
- Exclusão de pedidos
- Atualização automática após operações
- Design responsivo e intuitivo

---

## Arquitetura

### Backend (Rails)
```
API/
├── app/
│   ├── controllers/
│   │   └── orders_controller.rb      # Endpoints REST
│   ├── models/
│   │   └── order.rb                  # Model com validações e callbacks
│   └── services/
│       ├── state_machine.rb          # Lógica de transições de estado
│       └── status_appender.rb        # Adiciona status ao histórico
├── config/
│   ├── routes.rb                     # Rotas RESTful
│   └── initializers/cors.rb          # Configuração CORS
├── db/
│   ├── migrate/                      # Migrations
│   └── seeds/pedidos.json            # Dados iniciais
└── spec/                             # Testes RSpec
    ├── models/
    ├── requests/
    └── services/
```

**Padrões aplicados**:
- Service Objects para lógica de negócio complexa
- RESTful API design
- Test-Driven Development (TDD)
- Separation of Concerns

### Frontend (Flutter)
```
frontend/lib/
├── main.dart                         # Entry point
├── models/
│   ├── order.dart                    # Model de pedido
│   └── store.dart                    # Model de loja
├── pages/
│   └── home_page.dart                # Página principal
├── services/
│   └── orders_service.dart           # Comunicação HTTP com API
└── widgets/
    ├── dashboard_column.dart         # Coluna de pedidos por status
    ├── order_card.dart               # Card individual de pedido
    ├── stat_card.dart                # Card de estatísticas
    ├── new_order_dialog.dart         # Diálogo de criação
    └── order_dialog.dart             # Diálogo de detalhes
```

**Padrões aplicados**:
- Widget composition
- Service layer para isolamento de lógica HTTP
- Stateful widgets para gerenciamento de estado
- Material Design guidelines

---

## Como Executar

### Pré-requisitos
- Docker
- Docker Compose

### Execução com Docker (Recomendado)

```bash
# 1. Clone o repositório
git clone git@github.com:coffeelipe/delivery-api.git
cd delivery-api

# 2. Inicie os containers
docker compose up --build
```

Aguarde o build das imagens e a inicialização dos serviços. Quando estiver pronto:

- **Frontend**: http://localhost:8080
- **API**: http://localhost:3000

**Para instruções detalhadas de deploy, consulte [DEPLOYMENT.md](DEPLOYMENT.md)**

### Execução Manual (Sem Docker)

#### Backend
```bash
cd API
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server -b 0.0.0.0 -p 3000
```

#### Frontend
```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 8080
```

---

## Testes

### Backend (RSpec)
```bash
cd API
bundle exec rspec
```

Cobertura de testes:
- Models: validações, callbacks, geração de UUID
- Services: state machine, status appender
- Requests: endpoints CRUD e transições de status

### Frontend
Testes unitários e de widgets podem ser executados com:
```bash
cd frontend
flutter test
```

---

## Endpoints da API

### Listar todos os pedidos
```
GET /orders
```

### Buscar pedido específico
```
GET /orders/:id
```

### Criar novo pedido
```
POST /orders
Content-Type: application/json

{
  "store_id": "STORE123",
  "details": {
    "customer": "João Silva",
    "items": [...]
  }
}
```

### Excluir pedido
```
DELETE /orders/:id
```

### Avançar status do pedido
```
PATCH /orders/:id/status
```

### Cancelar pedido
```
PATCH /orders/:id/status?cancel=true
```

---

## Estrutura do Banco de Dados

### Tabela: orders

| Campo      | Tipo      | Descrição                              |
|------------|-----------|----------------------------------------|
| id         | string    | UUID único do pedido (PK)              |
| store_id   | string    | Identificador da loja                  |
| details    | json      | Dados do pedido (cliente, itens, etc.) |
| created_at | datetime  | Data de criação                        |
| updated_at | datetime  | Data de última atualização             |

O campo **details** contém:
```json
{
  "order_id": "uuid",
  "customer": "Nome do cliente",
  "items": [...],
  "statuses": [
    {
      "name": "RECEIVED",
      "origin": "STORE",
      "created_at": "2026-02-22T10:00:00Z"
    }
  ],
  "last_status_name": "RECEIVED"
}
```

---

## Abordagem de Desenvolvimento

O projeto foi desenvolvido seguindo metodologia **TDD (Test-Driven Development)**:

1. **Fase 1**: Setup Rails, Docker e RSpec
2. **Fase 2**: Backend com testes primeiro
   - Model Order com validações e callbacks
   - Service StatusAppender para gerenciar histórico
   - Service StateMachine para lógica de transições
   - Controller com endpoints CRUD
   - Integração com pedidos.json via seeds
3. **Fase 3**: Frontend Flutter
   - Models e services de integração
   - Dashboard com visualização por colunas
   - Cards de pedidos e estatísticas
   - Diálogos de criação e detalhes
   - Integração completa com API
4. **Fase 4**: Containerização e documentação
   - Docker e Docker Compose
   - Documentação técnica

Para detalhes completos do processo, consulte [BACKLOG.md](BACKLOG.md).

---

## Melhorias Futuras

Dado mais tempo, gostaria de implementar as seguintes melhorias:

### Segurança e Autenticação
- Sistema de autenticação JWT
- Autorização baseada em roles (admin, lojista, entregador)
- Validação robusta de input com sanitização

### Features Avançadas
- Notificações em tempo real via WebSockets ou Server-Sent Events
- Sistema de busca e filtros avançados (por data, status, loja)
- Paginação para grandes volumes de pedidos

### Performance e Escalabilidade
- PostgreSQL em vez de SQLite para produção
- Load balancing para múltiplas instâncias

### Mobile e Desktop
- Build completo para dispositivos móveis
- Aplicativos nativos para Windows, macOS, Linux
- Sincronização offline-first
- Push notifications mobile
- Responsividade da UI para diferentes dispositivos
---

## Licença

Este projeto foi desenvolvido para fins educacionais como parte de um desafio técnico.

---

## Contato

Desenvolvido por Felipe como parte do processo seletivo Coco Bambu.
fpontes.dev@gmail.com
