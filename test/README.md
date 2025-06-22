# Testes do ParkWallet

Este diretório contém os testes unitários e de widget para o aplicativo ParkWallet.

## Estrutura dos Testes

```
test/
├── README.md                           # Este arquivo
├── test_suite.dart                     # Suite completa de testes
├── widget_test.dart                    # Testes do widget principal
├── constants/
│   ├── app_colors_test.dart           # Testes das cores da aplicação
│   └── endpoints_test.dart            # Testes dos endpoints da API
├── global/
│   ├── language_controller_test.dart   # Testes do controlador de idioma
│   ├── custom_exception_test.dart      # Testes da exceção customizada
│   └── app_translations_test.dart      # Testes das traduções do app
├── routes/
│   └── app_routes_test.dart           # Testes das rotas da aplicação
├── services/
│   └── auth_service_test.dart         # Testes do serviço de autenticação
└── data/
    ├── dto/
    │   ├── login_request_test.dart      # Testes do DTO de requisição de login
    │   ├── transaction_test.dart        # Testes do DTO de transação
    │   └── transaction_item_test.dart   # Testes do DTO de item de transação
    └── models/
        ├── product_test.dart            # Testes do modelo de produto
        ├── user_profile_test.dart       # Testes do modelo de perfil do usuário
        └── store_test.dart              # Testes do modelo de loja
```

## Como Executar os Testes

### Executar todos os testes
```bash
flutter test
```

### Executar a suite completa de testes
```bash
flutter test test/test_suite.dart
```

### Executar testes específicos

#### Testes de widget
```bash
flutter test test/widget_test.dart
```

#### Testes de constantes
```bash
flutter test test/constants/app_colors_test.dart
```

#### Testes globais
```bash
flutter test test/global/language_controller_test.dart
flutter test test/global/custom_exception_test.dart
```

#### Testes de rotas
```bash
flutter test test/routes/app_routes_test.dart
```

#### Testes de serviços
```bash
flutter test test/services/auth_service_test.dart
```

### Executar testes com cobertura
```bash
flutter test --coverage
```

### Executar testes em modo verbose
```bash
flutter test --verbose
```

## Descrição dos Testes

### Widget Tests (`widget_test.dart`)
- Testa se o widget `MyApp` é construído corretamente
- Verifica se o widget é um `StatelessWidget`
- Testa se possui uma chave válida
- Verifica configurações básicas do app

### Constants Tests

#### App Colors Tests (`constants/app_colors_test.dart`)
- Verifica se todas as cores estão definidas corretamente
- Testa se os valores das cores são válidos
- Verifica se não há cores duplicadas
- Testa se os valores alpha estão corretos

#### Endpoints Tests (`constants/endpoints_test.dart`)
- Verifica se todos os endpoints estão definidos
- Testa se os endpoints contêm a URL base correta
- Verifica se os caminhos dos endpoints estão corretos
- Testa endpoints parametrizados com placeholders
- Verifica consistência entre endpoints de chat e socket

### Global Tests

#### Language Controller Tests (`global/language_controller_test.dart`)
- Testa o estado inicial do controlador
- Verifica mudanças de idioma e bandeira
- Testa caminhos das imagens das bandeiras
- Verifica atualizações de locale
- Testa reatividade do `flagImagePath`

#### Custom Exception Tests (`global/custom_exception_test.dart`)
- Testa criação de exceções com mensagens
- Verifica o método `toString`
- Testa se implementa a interface `Exception`
- Verifica se pode ser lançada como exceção



### Routes Tests

#### App Routes Tests (`routes/app_routes_test.dart`)
- Verifica se todas as rotas estão definidas
- Testa se as rotas começam com '/'
- Verifica unicidade das rotas
- Testa convenções de nomenclatura
- Verifica número esperado de rotas

### Services Tests

#### Auth Service Tests (`services/auth_service_test.dart`)
- Testa inicialização do token
- Verifica extração de `userId` de tokens JWT
- Testa tratamento de tokens inválidos
- Verifica validação de formato de token
- Testa herança de `GetxService`

### Data DTO Tests

#### Login Request Tests (`data/dto/login_request_test.dart`)
- Testa criação de requisições de login
- Verifica conversão para Map
- Testa tratamento de strings vazias e caracteres especiais
- Verifica modificação de campos
- Testa integridade dos dados

#### Transaction Tests (`data/dto/transaction_test.dart`)
- Testa criação de transações com itens
- Verifica criação a partir de JSON
- Testa tratamento de valores inválidos
- Verifica diferentes tipos de operação
- Testa representação toString

#### Transaction Item Tests (`data/dto/transaction_item_test.dart`)
- Testa criação de itens de transação
- Verifica criação a partir de JSON
- Testa diferentes formatos de valores
- Verifica tratamento de valores nulos/inválidos
- Testa cenários de e-commerce típicos

### Data Models Tests

#### Product Tests (`data/models/product_test.dart`)
- Testa criação de produtos com campos obrigatórios e opcionais
- Verifica criação a partir de JSON
- Testa fallback de `facilityId` para `storeId`
- Verifica tratamento de diferentes formatos de preço
- Testa valores zero e negativos

#### User Profile Tests (`data/models/user_profile_test.dart`)
- Testa criação de perfis de usuário
- Verifica criação a partir de JSON
- Testa diferentes formatos de data
- Verifica representação toString
- Testa tratamento de caracteres especiais

#### Store Tests (`data/models/store_test.dart`)
- Testa criação de lojas com campos obrigatórios e opcionais
- Verifica criação a partir de JSON
- Testa diferentes tipos de ID
- Verifica tratamento de strings vazias e caracteres especiais
- Testa vários tipos de loja

## Dependências de Teste

Os testes utilizam as seguintes dependências:
- `flutter_test`: Framework de testes do Flutter
- `get`: Para testes de controladores GetX
- Mocks e stubs quando necessário

## Notas Importantes

- Os testes são executados de forma isolada
- Dependências do GetX são resetadas antes de cada teste quando necessário
- Não há dependências externas nos testes
- Todos os testes usam mocks quando necessário
- Os testes focam na lógica de negócio, não em UI
- DTOs e Models são testados para serialização/deserialização JSON
- Constantes são verificadas para consistência e validade
- Serviços são testados para funcionalidades que não dependem de storage externo
- Todos os edge cases importantes são cobertos (valores nulos, vazios, inválidos)

## Próximos Passos

Para expandir a cobertura de testes, considere adicionar:
- Testes de integração para fluxos completos
- Testes de widgets para páginas específicas
- Testes de repositórios quando implementados
- Testes de controladores de páginas
- Testes de validação de formulários
- Testes de conectividade e APIs (com mocks)

## Adicionando Novos Testes

Para adicionar novos testes:

1. Crie o arquivo de teste na pasta apropriada seguindo a estrutura:
   - `test/constants/` - Para constantes
   - `test/global/` - Para controladores globais
   - `test/routes/` - Para rotas
   - `test/services/` - Para serviços
   - `test/data/dto/` - Para DTOs
   - `test/data/models/` - Para modelos
   - `test/pages/` - Para páginas (se necessário)

2. Importe o arquivo no `test_suite.dart`
3. Adicione o grupo de teste na função `main()` na categoria apropriada
4. Execute os testes para verificar se estão funcionando

Exemplo:
```dart
// Em test_suite.dart
import 'data/models/novo_modelo_test.dart' as novo_modelo_teste;

// Na função main(), na seção Data Models Tests
group('Novo Modelo Tests', novo_modelo_teste.main);
```

## Padrões de Teste

Todos os testes seguem padrões consistentes:
- **Nomenclatura**: `nome_do_arquivo_test.dart`
- **Estrutura**: Grupos organizados por funcionalidade
- **Cobertura**: Casos positivos, negativos e edge cases
- **Isolamento**: Cada teste é independente
- **Documentação**: Descrições claras do que está sendo testado

## Exemplo de Estrutura de Teste

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/path/to/your/class.dart';

void main() {
  group('YourClass Tests', () {
    late YourClass instance;

    setUp(() {
      instance = YourClass();
    });

    test('should do something', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = instance.doSomething(input);
      
      // Assert
      expect(result, 'expected_output');
    });
  });
}
```