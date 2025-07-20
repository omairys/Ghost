# 🚀 Ghost - SIMPLE

Solo 4 archivos. Todo lo que necesitas.

## � Desarrollo Local (SÚPER FÁCIL)

```bash
# Iniciar Ghost
./start-ghost.sh start

# Ver en: http://localhost:2368
# Admin: http://localhost:2368/ghost
```

```bash
# Otros comandos
./start-ghost.sh stop    # Detener
./start-ghost.sh logs    # Ver logs
./start-ghost.sh clean   # Limpiar todo
```

---

## 🚀 Render.com (Producción - GRATUITO)

### 1. Crear Web Service en Render
- Conecta este repositorio de GitHub
- Usa: `Dockerfile` (detecta automáticamente)

### 2. Variables de entorno
```
NODE_ENV=production
url=https://tu-app.onrender.com
```

### 3. ¡NO necesitas base de datos externa!
- Usa SQLite3 automáticamente
- El archivo `ghost.db` se crea solo
- Perfecto para la versión gratuita

¡Listo!

---

## � Solo 4 archivos importantes:

✅ **ESTOS SÍ**:
- `Dockerfile.render` → Render.com
- `docker-compose.simple.yml` → Local
- `start-ghost.sh` → Scripts
- `README-SIMPLE.md` → Este archivo

❌ **Ignora todo lo demás**

---

## 💡 Diferencias:

| | Local | Render.com (Gratuito) |
|---|-------|----------------------|
| **Base de datos** | SQLite | SQLite |
| **Comando** | `./start-ghost.sh start` | Se despliega automático |
| **URL** | http://localhost:2368 | https://tu-app.onrender.com |
| **Costo** | Gratis | Gratis |
