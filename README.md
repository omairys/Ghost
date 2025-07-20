# 🚀 Ghost Blog - Configuración Segura

## ⚠️ ANTI-PÉRDIDA DE DATOS

Esta configuración **previene que pierdas tu blog** como te pasó antes. Incluye:
- ✅ Volúmenes persistentes
- ✅ Backups automáticos  
- ✅ Configuración optimizada para Render FREE (0.1 CPU, 512MB)

## 🚀 Uso Rápido

### Local:
```bash
./ghost.sh start     # Iniciar con backup automático
./ghost.sh backup    # Backup manual
./ghost.sh status    # Ver estado
```

### Render.com:
1. **Configura Persistent Disk** (CRÍTICO):
   - Ve a Settings → Disks → Add Disk
   - Name: `ghost-data`
   - Mount Path: `/opt/render/project/src/ghost-data` 
   - Size: 1GB

2. **Edita `render.yaml`** y cambia:
   ```yaml
   - key: url
     value: https://TU-SITIO.onrender.com  # ← Tu URL real
   
   - key: mail__from  
     value: noreply@TU-DOMINIO.com         # ← Tu email real
   ```

3. **Deploy**:
   ```bash
   git add .
   git commit -m "Ghost seguro"
   git push
   ```

## 🛡️ Por qué NO se perderán los datos

- **Dockerfile**: Se adapta automáticamente a Render FREE/PAID
- **Disco Persistente**: Datos fuera del contenedor en `/opt/render/project/src/ghost-data`
- **Backups**: Automáticos antes de cada operación (3 en Render, 10 en local)
- **Variables correctas**: `GHOST_DATABASE_PATH` apunta al disco persistente

## 📁 Estructura simplificada

```
📁 Ghost/
├── 🐳 Dockerfile                  # UNIVERSAL: Se adapta a FREE/PAID automáticamente
├── ⚙️  render.yaml               # Configuración para Render con disco persistente
├── 🛡️  ghost.sh                   # UN SOLO script para todo
├── 📁 ghost-data/                # Datos persistentes (local)
└── 📁 backups/                   # Backups automáticos
```

## 🔧 Comandos del script

```bash
./ghost.sh start     # Iniciar (con backup automático)
./ghost.sh stop      # Detener
./ghost.sh restart   # Reiniciar (con backup)
./ghost.sh backup    # Backup manual
./ghost.sh restore   # Restaurar desde backup
./ghost.sh status    # Ver estado y backups
./ghost.sh logs      # Ver logs
```

## 🆘 Recuperación de emergencia

1. **Exporta regularmente**: `/ghost/#/settings/labs` → Export content
2. **Si pierdes datos**: Busca backups en `/opt/render/project/src/ghost-data/backups/`
3. **Contacta Render Support** si es necesario

## ✅ Checklist

- [ ] Persistent Disk configurado en Render
- [ ] URLs cambiadas en `render.yaml`
- [ ] Primer backup: `./ghost.sh backup`
- [ ] Export desde Ghost Admin

---

**¡Nunca más perderás tu blog!** 🛡️

## URLs importantes

- **Local**: http://localhost:2368 | Admin: http://localhost:2368/ghost
- **Render**: https://tu-sitio.onrender.com | Admin: https://tu-sitio.onrender.com/ghost
