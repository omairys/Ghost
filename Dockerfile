# Dockerfile para Render.com
FROM ghost:latest

# Variables de entorno para producción
ENV NODE_ENV=production
ENV database__client=pg
