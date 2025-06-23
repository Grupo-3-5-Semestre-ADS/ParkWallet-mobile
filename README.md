# ParkWallet Mobile

Aplicativo para pagamento interno do parque e resort Itaipuland.

## 📱 Sobre o Projeto

O ParkWallet é um aplicativo móvel desenvolvido em Flutter que permite aos usuários realizar pagamentos internos no parque e resort Itaipuland. O app oferece funcionalidades como:

- 🔐 Autenticação de usuários
- 💳 Gerenciamento de saldo
- 🏪 Visualização de lojas e atrações
- 📱 Pagamento via QR Code
- 📊 Histórico de transações
- 👤 Gerenciamento de perfil
- 🌍 Suporte a múltiplos idiomas

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.7.2 ou superior
- Dart SDK
- Android Studio / VS Code

### Instalação
```bash
# Clone o repositório
git clone <repository-url>
cd ParkWallet-mobile

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run
```

## 🧪 Testes

O projeto possui uma estrutura completa de testes unitários com cobertura de código.

### Executar Testes
```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Usar script automatizado
./scripts/run_tests.sh
```

### Estrutura dos Testes
```
test/
├── unit/
│   ├── controllers/     # Testes dos controllers
│   └── repositories/    # Testes dos repositories
├── test_config.dart     # Configuração global
└── all_tests.dart       # Execução de todos os testes
```

### Cobertura de Código
- **Threshold mínimo**: 70% de cobertura
- **Relatório HTML**: `coverage/html/index.html`
- **Formato LCOV**: `coverage/lcov.info`

### Controllers Testados
- ✅ LoginController
- ✅ RegisterController  
- ✅ ProfileController
- ✅ HomeCreditController
- ✅ LanguageController

### Repositories Testados
- ✅ AuthRepository

Para mais detalhes sobre os testes, consulte [test/README.md](test/README.md).

## 🏗️ Arquitetura

O projeto utiliza:

- **GetX**: Gerenciamento de estado e navegação
- **Repository Pattern**: Separação de responsabilidades
- **Service Layer**: Lógica de negócio
- **DTO Pattern**: Transferência de dados
- **Dependency Injection**: Injeção de dependências

## 📁 Estrutura do Projeto

```
lib/
├── constants/          # Constantes e configurações
├── data/
│   ├── dto/           # Data Transfer Objects
│   └── models/        # Modelos de dados
├── global/            # Configurações globais
├── pages/             # Páginas da aplicação
│   ├── controllers/   # Controllers das páginas
│   └── widgets/       # Widgets específicos
├── repositories/      # Camada de acesso a dados
├── routes/            # Configuração de rotas
├── services/          # Serviços da aplicação
└── widgets/           # Widgets compartilhados
```

## 🔧 Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **GetX**: Gerenciamento de estado e navegação
- **HTTP**: Requisições HTTP
- **Socket.IO**: Comunicação em tempo real
- **Google Maps**: Integração com mapas
- **QR Code Scanner**: Leitura de códigos QR
- **Shared Preferences**: Armazenamento local
- **Mockito**: Testes unitários

## 📊 CI/CD

O projeto utiliza GitHub Actions para:

- ✅ Execução automática de testes
- 📊 Geração de relatórios de cobertura
- 🔍 Verificação de qualidade de código
- 🚀 Deploy automático

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Commit
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação de código
- `refactor`: Refatoração
- `test`: Adição ou correção de testes
- `chore`: Tarefas de manutenção

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Suporte

Para suporte, entre em contato através do WhatsApp: +55 45 99388-3277
