# Dockerfile UNIVERSAL para Ghost - Supabase PostgreSQL + SQLite híbrido
# Funciona con Supabase (Render FREE) y SQLite (desarrollo local)
FROM ghost:alpine

# Instalar driver de PostgreSQL para conexión a Supabase

USER root
RUN npm install pg --save

# Variables de entorno base - Detección automática de DB
ENV NODE_ENV=production

# Configuración híbrida: PostgreSQL (Supabase) o SQLite (local)
ENV database__client=${DATABASE_CLIENT:-sqlite3}
ENV database__connection__host=${DATABASE_HOST:-}
ENV database__connection__user=${DATABASE_USER:-postgres}
ENV database__connection__password=${DATABASE_PASSWORD:-}
ENV database__connection__database=${DATABASE_NAME:-postgres}
ENV database__connection__port=${DATABASE_PORT:-5432}
ENV database__connection__ssl=${DATABASE_SSL:-true}

# Fallback a SQLite para desarrollo local
ENV database__connection__filename=${GHOST_DATABASE_PATH:-/var/lib/ghost/content/data/ghost.db}
ENV database__useNullAsDefault=true
ENV database__debug=false

# Configuración SSL para Supabase
ENV database__connection__ssl__rejectUnauthorized=false

# Configuración de correo para evitar warnings
ENV mail__transport=Direct
ENV mail__from=noreply@yourdomain.com

# Optimizado para Render FREE (0.1 CPU, 512MB RAM)
ENV NODE_OPTIONS="--max-old-space-size=384"

# Configuración adaptativa de logging
ENV logging__level=warn
ENV logging__rotation__enabled=false

# Pool de DB optimizado para recursos limitados y PostgreSQL
ENV database__pool__min=1
ENV database__pool__max=3
ENV database__acquireConnectionTimeout=30000

# Caching agresivo para mejor performance
ENV caching__frontend__maxAge=31536000
ENV caching__301__maxAge=31536000
ENV caching__customRedirects__maxAge=31536000
ENV caching__favicon__maxAge=86400

# Crear estructura solo para archivos (imágenes, temas) - BD en Supabase
RUN mkdir -p /var/lib/ghost/content/data && \
    mkdir -p /var/lib/ghost/content/images && \
    mkdir -p /var/lib/ghost/content/themes && \
    mkdir -p /var/lib/ghost/content/logs && \
    chown -R node:node /var/lib/ghost/content

# Script inteligente que detecta Supabase o SQLite (SIN backups para PostgreSQL)
# Crear en directorio accesible para usuario node
RUN mkdir -p /home/node/bin
COPY <<EOF /home/node/bin/start-ghost.sh
#!/bin/sh
echo "=== Ghost Startup - latinhub-blog-db Config ==="

# Detectar si tenemos configuración de Supabase PostgreSQL
if [ -n "\$DATABASE_HOST" ] && [ -n "\$DATABASE_PASSWORD" ]; then
    echo "✅ Supabase PostgreSQL detectado"
    echo "Host: \$DATABASE_HOST"
    echo "Database: \$DATABASE_NAME"
    echo "Project: latinhub-blog-db"
    echo "📊 Backups: Automáticos en Supabase (no se requieren manuales)"

    # Configurar Ghost para PostgreSQL
    export database__client=pg
    export database__connection__host="\$DATABASE_HOST"
    export database__connection__user="\$DATABASE_USER"
    export database__connection__password="\$DATABASE_PASSWORD"
    export database__connection__database="\$DATABASE_NAME"
    export database__connection__port="\$DATABASE_PORT"
    export database__connection__ssl="\$DATABASE_SSL"
    export database__connection__ssl__rejectUnauthorized=false

    echo "🚀 Iniciando Ghost con Supabase PostgreSQL..."
else
    echo "📂 Fallback a SQLite (desarrollo local)"
    export database__client=sqlite3
    export database__connection__filename="/var/lib/ghost/content/data/ghost.db"

    # Crear directorio para SQLite si no existe
    mkdir -p /var/lib/ghost/content/data
    echo "⚠️  SQLite: Considera hacer backups manuales para desarrollo"

    echo "🚀 Iniciando Ghost con SQLite..."
fi

# Mostrar configuración final
echo "Cliente DB: \$database__client"
if [ "\$database__client" = "pg" ]; then
    echo "PostgreSQL Host: \$database__connection__host"
    echo "🔒 Datos seguros en Supabase con backups automáticos"
else
    echo "SQLite Path: \$database__connection__filename"
fi

# Iniciar Ghost
exec node current/index.js
EOF


RUN chmod +x /home/node/bin/start-ghost.sh && \
    chown -R node:node /home/node/bin

# Usar usuario no-root para seguridad
USER node

# Usar usuario no-root para seguridad
USER node

# Exponer puerto
EXPOSE 2368

# Volumen solo para archivos (imágenes, temas) - BD en Supabase
VOLUME ["/var/lib/ghost/content"]

# Usar nuestro script de detección automática desde directorio del usuario
CMD ["/home/node/bin/start-ghost.sh"]
