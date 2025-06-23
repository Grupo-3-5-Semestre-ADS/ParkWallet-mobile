#!/bin/bash

echo "🚀 Iniciando execução de testes unitários com cobertura..."

# Gera os mocks necessários
echo "📝 Gerando mocks..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Executa os testes unitários com cobertura
echo "🧪 Executando testes unitários..."
flutter test --coverage

# Verifica se o lcov está instalado
if ! command -v lcov &> /dev/null; then
    echo "⚠️  lcov não encontrado. Instalando..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S lcov
    elif command -v apt &> /dev/null; then
        sudo apt-get install lcov
    elif command -v brew &> /dev/null; then
        brew install lcov
    else
        echo "❌ Não foi possível instalar lcov automaticamente. Instale manualmente."
        exit 1
    fi
fi

# Gera relatório HTML de cobertura
echo "📊 Gerando relatório HTML de cobertura..."
genhtml coverage/lcov.info -o coverage/html

echo "✅ Testes concluídos!"
echo "📁 Relatório de cobertura disponível em: coverage/html/index.html"
echo "📈 Cobertura de código:"
lcov --summary coverage/lcov.info 