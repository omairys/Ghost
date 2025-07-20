# Dockerfile para Render.com (versión gratuita con SQLite3)
FROM ghost:latest

# Variables de entorno para SQLite3 (sin base de datos externa)
ENV NODE_ENV=production
ENV database__client=sqlite3
ENV database__connection__filename=/var/lib/ghost/content/data/ghost.db
ENV database__useNullAsDefault=true
ENV database__debug=false

# Crear directorio para la base de datos
RUN mkdir -p /var/lib/ghost/content/data

# SQLite3 ya viene incluido en la imagen de Ghost
