# Dockerfile para Render.com (versión gratuita optimizada)
FROM ghost:latest

# Cambiar a usuario root temporalmente para instalar dependencias
USER root

# Instalar el driver de PostgreSQL de forma eficiente
RUN cd /var/lib/ghost/versions/*/. && npm install pg --save --no-optional

# Volver al usuario ghost
USER node

# Variables de entorno para Render.com
ENV NODE_ENV=production
ENV database__client=pg
