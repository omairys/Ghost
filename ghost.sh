#!/bin/bash

# Script UNIVERSAL para Ghost - Seguro y simple
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"; exit 1; }

# Detectar Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    error "Docker Compose no disponible"
fi

mkdir -p ./ghost-data ./backups

show_help() {
    echo "🚀 Ghost - Script Universal (Supabase + SQLite)"
    echo ""
    echo "Comandos:"
    echo "  start     Iniciar Ghost (Supabase en Render, SQLite local)"
    echo "  stop      Detener Ghost"
    echo "  restart   Reiniciar Ghost"
    echo "  logs      Ver logs"
    echo "  backup    Crear backup (solo SQLite local)"
    echo "  restore   Restaurar desde backup (solo SQLite local)" 
    echo "  status    Ver estado y info"
    echo "  clean     Limpiar todo (¡PELIGRO!)"
    echo ""
    echo "📊 Supabase: Backups automáticos, no necesitas backup manual"
}

start_ghost() {
    [ ! -f ".env" ] && cp .env.example .env
    
    log "Iniciando Ghost..."
    
    # Backup antes de iniciar
    if [ -f "./ghost-data/data/ghost.db" ]; then
        create_backup "pre-start"
    fi
    
    $DOCKER_COMPOSE -f docker-compose.production.yml up -d
    log "✅ Ghost iniciado!"
    log "🌐 Blog: http://localhost:2368"
    log "⚙️  Admin: http://localhost:2368/ghost"
}

stop_ghost() {
    log "Deteniendo Ghost..."
    $DOCKER_COMPOSE -f docker-compose.production.yml down
    log "Ghost detenido"
}

restart_ghost() {
    create_backup "pre-restart"
    stop_ghost
    sleep 2
    start_ghost
}

show_logs() {
    $DOCKER_COMPOSE -f docker-compose.production.yml logs -f
}

create_backup() {
    local type=${1:-manual}
    local date=$(date +%Y%m%d_%H%M%S)
    
    # Solo hacer backup para SQLite local
    if [ -f "./ghost-data/data/ghost.db" ]; then
        cp "./ghost-data/data/ghost.db" "./backups/ghost_${type}_${date}.db"
        log "✅ Backup SQLite: ghost_${type}_${date}.db"
        
        # Mantener últimos 10 backups
        ls -t ./backups/ghost_*.db | tail -n +11 | xargs rm -f 2>/dev/null || true
        
        local size=$(du -h "./backups/ghost_${type}_${date}.db" | cut -f1)
        log "Tamaño: $size"
    else
        warn "SQLite no encontrado (probablemente usando Supabase PostgreSQL)"
        warn "📊 Supabase maneja backups automáticamente - no necesitas backup manual"
    fi
}

restore_backup() {
    echo "Backups disponibles:"
    ls -la ./backups/*.db 2>/dev/null || error "No hay backups"
    
    echo -n "Nombre del backup: "
    read -r backup_file
    
    [ ! -f "./backups/$backup_file" ] && error "Backup no encontrado"
    
    warn "¿Restaurar? Sobrescribirá datos actuales (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY])$ ]]; then
        create_backup "pre-restore"
        stop_ghost
        cp "./backups/$backup_file" "./ghost-data/data/ghost.db"
        log "✅ Restaurado: $backup_file"
        start_ghost
    fi
}

show_status() {
    echo "📊 Estado de Ghost:"
    $DOCKER_COMPOSE -f docker-compose.production.yml ps
    
    echo ""
    if [ -f "./ghost-data/data/ghost.db" ]; then
        local size=$(du -h "./ghost-data/data/ghost.db" | cut -f1)
        echo "💾 Base de datos: $size"
    else
        echo "💾 Base de datos: No encontrada"
    fi
    
    local backup_count=$(ls ./backups/*.db 2>/dev/null | wc -l)
    echo "📦 Backups: $backup_count disponibles"
}

clean_all() {
    warn "¿Eliminar TODO? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY])$ ]]; then
        $DOCKER_COMPOSE -f docker-compose.production.yml down -v
        rm -rf ./ghost-data ./backups
        log "Limpieza completada"
    fi
}

case ${1:-help} in
    start) start_ghost ;;
    stop) stop_ghost ;;
    restart) restart_ghost ;;
    logs) show_logs ;;
    backup) create_backup ;;
    restore) restore_backup ;;
    status) show_status ;;
    clean) clean_all ;;
    *) show_help ;;
esac
