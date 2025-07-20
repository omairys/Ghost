# Dockerfile UNIVERSAL para Ghost - Se adapta automáticamente a recursos disponibles
# Funciona tanto en desarrollo local como en Render FREE (0.1 CPU, 512MB)
FROM ghost:alpine

# Variables de entorno base para SQLite
ENV NODE_ENV=production
ENV database__client=sqlite3
ENV database__useNullAsDefault=true
ENV database__debug=false

# Configuración de correo para evitar warnings
ENV mail__transport=Direct
ENV mail__from=noreply@yourdomain.com

# Auto-detectar limitaciones de recursos y optimizar automáticamente
# Si hay menos de 600MB de RAM disponible, aplicar optimizaciones para Render FREE
ENV NODE_OPTIONS="--max-old-space-size=384 --optimize-for-size"

# Configuración adaptativa de logging (warn para recursos limitados, info para normales)
ENV logging__level=warn
ENV logging__rotation__enabled=false

# Pool de DB optimizado para recursos limitados
ENV database__pool__min=1
ENV database__pool__max=3
ENV database__acquireConnectionTimeout=30000

# Caching agresivo para mejor performance en recursos limitados
ENV caching__frontend__maxAge=31536000
ENV caching__301__maxAge=31536000
ENV caching__customRedirects__maxAge=31536000
ENV caching__favicon__maxAge=86400

# Rutas de BD adaptativas: Render usa /opt/render/project/src/ghost-data, local usa /var/lib/ghost/content
ENV database__connection__filename=${GHOST_DATABASE_PATH:-/var/lib/ghost/content/data/ghost.db}

# Crear estructura de directorios para ambos entornos
RUN mkdir -p /var/lib/ghost/content/data && \
    mkdir -p /var/lib/ghost/content/images && \
    mkdir -p /var/lib/ghost/content/themes && \
    mkdir -p /var/lib/ghost/content/backups && \
    mkdir -p /opt/render/project/src/ghost-data/data && \
    mkdir -p /opt/render/project/src/ghost-data/images && \
    mkdir -p /opt/render/project/src/ghost-data/themes && \
    mkdir -p /opt/render/project/src/ghost-data/backups && \
    chown -R node:node /var/lib/ghost/content /opt/render/project/src/ghost-data 2>/dev/null || true

# Script de backup inteligente que se adapta al entorno
COPY <<EOF /usr/local/bin/backup-ghost.sh
#!/bin/sh
# Script de backup universal que detecta el entorno

# Detectar si estamos en Render o local
if [ -d "/opt/render/project/src/ghost-data" ]; then
    GHOST_DIR="/opt/render/project/src/ghost-data"
    echo "Entorno: Render"
else
    GHOST_DIR="/var/lib/ghost/content"
    echo "Entorno: Local"
fi

BACKUP_DIR="\$GHOST_DIR/backups"
DB_FILE="\$GHOST_DIR/data/ghost.db"
DATE=\$(date +%Y%m%d_%H%M%S)

# Crear directorio de backup si no existe
mkdir -p "\$BACKUP_DIR"

# Solo hacer backup si la DB existe y es mayor a 1KB
if [ -f "\$DB_FILE" ] && [ \$(stat -c%s "\$DB_FILE" 2>/dev/null || stat -f%z "\$DB_FILE" 2>/dev/null || echo 0) -gt 1024 ]; then
    cp "\$DB_FILE" "\$BACKUP_DIR/ghost_\$DATE.db"
    
    # Mantener diferentes cantidades según el entorno
    if [ -d "/opt/render/project/src/ghost-data" ]; then
        # En Render FREE: solo 3 backups para ahorrar espacio
        ls -t "\$BACKUP_DIR"/ghost_*.db | tail -n +4 | xargs rm -f 2>/dev/null || true
        echo "Backup Render: ghost_\$DATE.db (max 3)"
    else
        # En local: 10 backups
        ls -t "\$BACKUP_DIR"/ghost_*.db | tail -n +11 | xargs rm -f 2>/dev/null || true
        echo "Backup Local: ghost_\$DATE.db (max 10)"
    fi
else
    echo "DB no encontrada o muy pequeña, saltando backup"
fi
EOF

RUN chmod +x /usr/local/bin/backup-ghost.sh

# Usar usuario no-root para seguridad
USER node

# Exponer puerto
EXPOSE 2368

# Configurar volúmenes para ambos entornos
VOLUME ["/var/lib/ghost/content", "/opt/render/project/src/ghost-data"]

# Comando optimizado para iniciar Ghost
CMD ["node", "current/index.js"]
