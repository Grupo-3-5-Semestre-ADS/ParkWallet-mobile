# Aplicativo Mobile - ParkWallet

Este repositório contém o código-fonte do aplicativo mobile do ParkWallet. Desenvolvido com Flutter e utilizando GetX para gerenciamento de estado, rotas e injeção de dependências, este aplicativo visa fornecer uma interface intuitiva e eficiente para os usuários interagirem com os serviços da plataforma ParkWallet.

## Visão Geral da Arquitetura Mobile

O aplicativo mobile ParkWallet é construído sobre o framework Flutter, permitindo uma base de código única para plataformas Android. Ele se comunica com o backend do ParkWallet através do API Gateway, consumindo os microserviços para realizar suas funcionalidades.

A arquitetura interna do aplicativo segue padrões recomendados para projetos Flutter com GetX, buscando:

*   **Modularidade**: Divisão das funcionalidades em módulos (ex: autenticação, catálogo, carteira).
*   **Reatividade**: Utilização do GetX para gerenciamento de estado reativo, facilitando a atualização da UI em resposta a mudanças de dados.
*   **Navegação Simplificada**: Gerenciamento de rotas com GetX.
*   **Injeção de Dependências**: Uso do GetX para gerenciar dependências de controllers, services, etc.

## Funcionalidades Principais

O aplicativo mobile implementa as seguintes funcionalidades, correspondentes aos serviços do backend (exceto notificações):

*   **Gerenciamento de Usuários**:
    *   Cadastro de novos usuários.
    *   Autenticação (Login/Logout).
    *   Gerenciamento de perfil do usuário.
*   **Catálogo de Produtos/Estabelecimentos**:
    *   Visualização de estabelecimentos (lojas, etc.).
    *   Busca e filtros de estabelecimentos.
    *   Detalhes dos estabelecimentos.
*   **Transações**:
    *   Visualização do histórico de transações.
    *   Realização de pagamentos/operações.
*   **Carteira Digital**:
    *   Visualização de saldo.
    *   Gerenciamento da carteira digital (ex: adicionar fundos).
*   **Chat em Tempo Real**:
    *   Comunicação via chat com o suporte.

## Tecnologias Utilizadas

*   **Flutter**: Framework UI do Google para construir aplicativos compilados nativamente para mobile, web e desktop a partir de uma única base de código.
*   **Dart**: Linguagem de programação otimizada para clientes, usada pelo Flutter.
*   **GetX**: Um microframework poderoso e leve para Flutter, utilizado para:
    *   Gerenciamento de Estado (Simple State Manager e Reactive State Manager - GetBuilder, Obx).
    *   Gerenciamento de Rotas.
    *   Injeção de Dependências.
*   **HTTP Client**: Para realizar requisições à API do backend.

## Pré-requisitos

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Verifique a versão no `pubspec.yaml` do projeto)
*   Um IDE configurado para desenvolvimento Flutter:
    *   [Android Studio](https://developer.android.com/studio) (com plugins Flutter e Dart)
    *   [Visual Studio Code](https://code.visualstudio.com/) (com extensões Flutter e Dart)
*   Um emulador Android / dispositivo físico Android.
*   **O backend do ParkWallet deve estar rodando e acessível pela rede.** (Consulte o [README do Backend](https://github.com/Grupo-3-5-Semestre-ADS/ParkWallet-backend.git) para instruções de setup).

## Como Iniciar

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/Grupo-3-5-Semestre-ADS/ParkWallet-mobile
    cd ParkWallet-mobile
    ```

2.  **Estrutura de Diretórios (Exemplo com GetX):**
    A estrutura do projeto segue um padrão comum para aplicações Flutter com GetX, organizando o código por funcionalidades e camadas:

    ```
    parkwallet_mobile/
    ├── android/                  # Código específico para Android
    ├── assets/
    │   ├── images/               # Imagens (logos, ícones de pins, bandeiras, etc.)
    │   │   └── pins/
    │   └── map_style.json        # Estilo customizado para o mapa (Google Maps)
    ├── lib/
    │   ├── main.dart             # Ponto de entrada da aplicação
    │   ├── constants/            # Constantes globais
    │   │   ├── app_colors.dart
    │   │   ├── endpoints.dart    # Endpoints da API
    │   │   ├── map_config.dart
    │   │   └── input_formatters/ # Formatadores de entrada de texto
    │   ├── data/                 # Camada de dados
    │   │   ├── dto/              # Data Transfer Objects (para requisições/respostas API)
    │   │   └── models/           # Modelos de dados da aplicação (Product, Store, UserProfile, etc.)
    │   ├── global/               # Configurações e utilitários globais
    │   │   ├── app_translations.dart
    │   │   ├── custom_exception.dart
    │   │   └── language_controller.dart
    │   ├── pages/                # Telas/Páginas da aplicação, organizadas por feature
    │   │   ├── chat/
    │   │   │   ├── chat_binding.dart
    │   │   │   ├── chat_controller.dart
    │   │   │   ├── chat_page.dart
    │   │   │   └── widgets/     
    │   │   ├── history/
    │   │   │   ├── controllers/
    │   │   │   ├── history_binding.dart
    │   │   │   └── history_page.dart
    │   │   ├── home/
    │   │   │   ├── controllers/
    │   │   │   ├── home_binding.dart
    │   │   │   ├── home_page.dart
    │   │   │   └── widgets/      
    │   │   ├── login/
    │   │   │   ├── controllers/
    │   │   │   └── login_page.dart
    │   │   ├── map/
    │   │   │   ├── controllers/
    │   │   │   ├── models/     
    │   │   │   ├── services/  
    │   │   │   ├── map_binding.dart
    │   │   │   ├── map_page.dart
    │   │   │   └── widgets/      
    │   │   ├── profile/
    │   │   │   ├── controllers/
    │   │   │   ├── pages/     
    │   │   │   ├── profile_binding.dart
    │   │   │   ├── profile_page.dart
    │   │   │   └── widgets/
    │   │   ├── register/
    │   │   │   ├── controllers/
    │   │   │   ├── regsiter_binding.dart
    │   │   │   ├── register_page.dart
    │   │   │   └── widgets/     
    │   │   ├── stores/
    │   │   │   ├── controllers/
    │   │   │   ├── stores_binding.dart
    │   │   │   ├── stores_page.dart
    │   │   │   ├── store_detail_binding.dart
    │   │   │   └── store_detail_page.dart
    │   │   └── widgets/          # Widgets comuns reutilizáveis em várias páginas/features
    │   ├── repositories/         # Repositórios (abstração da lógica de acesso a dados - API, local)
    │   │   ├── auth_repository.dart
    │   │   ├── chat_repository.dart
    │   │   └── ...               # Outros repositórios (credit, history, product, etc.)
    │   ├── routes/               # Configuração de rotas da aplicação (GetX)
    │   │   ├── app_pages.dart
    │   │   └── app_routes.dart
    │   └── services/             # Serviços da aplicação (lógica de negócio, middlewares)
    │       ├── auth_middleware.dart
    │       ├── auth_service.dart
    │       ├── chat_service.dart
    │       └── ...               # Outros serviços
    ├── test/
    │   └── widget_test.dart      # Testes de widgets e unitários
    ```
    *Nota: As pastas `android/`, `ios/`, `linux/` e `web/` contêm código e configurações específicas de cada plataforma, geradas e gerenciadas principalmente pelo Flutter.*

3.  **Instale as dependências:**
    No diretório raiz do projeto, execute:
    ```bash
    flutter pub get
    ```

4.  **Configure a URL da API do Backend:**
    Verifique se a URL base para o API Gateway do backend está corretamente configurada no aplicativo. Geralmente, isso é feito em um arquivo de configuração dentro de `lib/app/core/config/` ou similar.
    Exemplo:
    ```dart
    // lib/constants/endpoints.dart
    class Endpoints {
      static const uriServidor = "[SEU_IP_OU_DOMINIO_DO_BACKEND]";
    }
    ```
    Certifique-se de que `SEU_IP_OU_DOMINIO_DO_BACKEND` seja acessível a partir do seu dispositivo/emulador. Se estiver rodando o backend localmente e o app no emulador Android, `localhost` geralmente é mapeado para `10.0.2.2`.

5.  **Execute o aplicativo:**
    Conecte um dispositivo ou inicie um emulador/simulador e execute:
    ```bash
    flutter run
    ```
    Para escolher um dispositivo específico, se vários estiverem conectados:
    ```bash
    flutter run -d [DEVICE_ID]
    ```
    Você pode listar os dispositivos disponíveis com `flutter devices`.

## Comunicação com o Backend

O aplicativo mobile se comunica com o **API Gateway** do backend ParkWallet. Todos os endpoints e a lógica de negócios residem no backend. Consulte a documentação do [README do Backend](https://github.com/Grupo-3-5-Semestre-ADS/ParkWallet-backend.git) para detalhes.

## Configurações

*   **URL da API**: Como mencionado acima, a URL base do API Gateway é a configuração mais crucial.
