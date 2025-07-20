#!/bin/bash

# Script SIMPLE para Ghost
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Detectar Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    error "Docker Compose no está disponible."
fi

show_help() {
    echo "🚀 Ghost - Script SIMPLE"
    echo ""
    echo "Comandos:"
    echo "  start     Iniciar Ghost (SQLite)"
    echo "  stop      Detener Ghost"
    echo "  logs      Ver logs"
    echo "  clean     Limpiar todo"
    echo "  help      Mostrar ayuda"
}

start_ghost() {
    log "Iniciando Ghost..."
    $DOCKER_COMPOSE -f docker-compose.simple.yml up -d
    log "✅ Ghost iniciado!"
    log "🌐 Ve a: http://localhost:2368"
    log "⚙️  Admin: http://localhost:2368/ghost"
}

stop_ghost() {
    log "Deteniendo Ghost..."
    $DOCKER_COMPOSE -f docker-compose.simple.yml down
    log "Ghost detenido"
}

show_logs() {
    $DOCKER_COMPOSE -f docker-compose.simple.yml logs -f
}

clean_all() {
    warn "¿Eliminar todo? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY])$ ]]; then
        log "Limpiando..."
        $DOCKER_COMPOSE -f docker-compose.simple.yml down -v
        log "Limpieza completada"
    else
        log "Cancelado"
    fi
}

case ${1:-help} in
    start) start_ghost ;;
    stop) stop_ghost ;;
    logs) show_logs ;;
    clean) clean_all ;;
    *) show_help ;;
esac
