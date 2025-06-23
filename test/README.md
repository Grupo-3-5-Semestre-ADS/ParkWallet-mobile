# Testes Unitários - ParkWallet Mobile

Este diretório contém os testes unitários para o projeto ParkWallet Mobile.

## Estrutura dos Testes

```
test/
├── unit/
│   ├── controllers/           # Testes dos controllers
│   │   ├── login_controller_test.dart
│   │   ├── register_controller_test.dart
│   │   ├── profile_controller_test.dart
│   │   ├── home_credit_controller_test.dart
│   │   └── language_controller_test.dart
│   └── repositories/          # Testes dos repositories
│       └── auth_repository_test.dart
├── test_config.dart           # Configuração global para testes
├── all_tests.dart            # Arquivo para executar todos os testes
└── widget_test.dart          # Teste de widget padrão do Flutter
```

## Como Executar os Testes

### 1. Executar todos os testes
```bash
flutter test
```

### 2. Executar testes com cobertura
```bash
flutter test --coverage
```

### 3. Usar o script automatizado
```bash
./scripts/run_tests.sh
```

### 4. Executar testes específicos
```bash
# Testes de controllers
flutter test test/unit/controllers/

# Teste específico
flutter test test/unit/controllers/login_controller_test.dart
```

## Gerando Mocks

Antes de executar os testes, é necessário gerar os mocks:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Relatório de Cobertura

Após executar os testes com cobertura, você pode:

1. **Ver o resumo no terminal:**
   ```bash
   lcov --summary coverage/lcov.info
   ```

2. **Abrir o relatório HTML:**
   ```bash
   open coverage/html/index.html
   ```

3. **Verificar thresholds:**
   - Statements: 70%
   - Branches: 60%
   - Functions: 70%
   - Lines: 70%

## Padrões de Teste

### Estrutura dos Testes
Cada teste segue o padrão **AAA (Arrange-Act-Assert)**:

```dart
test('descrição do teste', () {
  // Arrange - Preparar dados e mocks
  final controller = LoginController();
  controller.emailCtrl.text = 'test@example.com';
  
  // Act - Executar a ação
  final result = controller.validateEmail();
  
  // Assert - Verificar resultado
  expect(result, true);
});
```

### Grupos de Teste
Os testes são organizados em grupos lógicos:

```dart
group('Validação de campos', () {
  test('deve validar email correto', () { ... });
  test('deve rejeitar email inválido', () { ... });
});
```

### Mocks
Utilizamos Mockito para criar mocks das dependências:

```dart
@GenerateMocks([AuthRepository, AuthService])
void main() {
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(mockAuthRepository.fetchLogin(any))
        .thenAnswer((_) async => 'token');
  });
}
```

## Controllers Testados

### LoginController
- ✅ Validação de campos (email, senha)
- ✅ Login bem-sucedido
- ✅ Tratamento de erros
- ✅ Estados de loading
- ✅ Métodos auxiliares

### RegisterController
- ✅ Validação da primeira página (nome, CPF, data)
- ✅ Validação da segunda página (email, senha)
- ✅ Navegação entre páginas
- ✅ Registro de usuário
- ✅ Tratamento de erros

### ProfileController
- ✅ Carregamento de dados do perfil
- ✅ Validação de formulário
- ✅ Atualização de perfil
- ✅ Formatação de dados
- ✅ Estados reativos

### HomeCreditController
- ✅ Carregamento de saldo
- ✅ Estados de loading
- ✅ Navegação
- ✅ Estados reativos

### LanguageController
- ✅ Mudança de idioma
- ✅ Configuração de flags
- ✅ Estados reativos
- ✅ Integração com GetX

## Repositories Testados

### AuthRepository
- ✅ Login com sucesso
- ✅ Login com erro
- ✅ Registro com sucesso
- ✅ Registro com erro
- ✅ Headers corretos
- ✅ Serialização de dados

## Configuração de Teste

O arquivo `test_config.dart` contém:

- Configuração do ambiente de teste
- Setup do GetX para testes
- Mixin para facilitar testes de controllers

## Dependências de Teste

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
  test: ^1.24.9
  coverage: ^1.6.3
```

## Boas Práticas

1. **Teste um comportamento por vez**
2. **Use nomes descritivos para os testes**
3. **Organize testes em grupos lógicos**
4. **Mantenha testes independentes**
5. **Use mocks para dependências externas**
6. **Teste casos de sucesso e erro**
7. **Mantenha alta cobertura de código**

## Troubleshooting

### Erro: "Mock not found"
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Erro: "GetX not initialized"
Certifique-se de que `TestConfig.setupTestEnvironment()` é chamado no `setUp`.

### Cobertura baixa
Verifique se todos os métodos públicos estão sendo testados e se os casos de erro estão cobertos. 