#!/bin/bash
set -e

# Script de backup para Poste.io
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="poste_backup_$DATE.tar.gz"

echo "🗄️  Creando backup de Poste.io..."

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Parar servicios temporalmente para backup consistente
echo "Deteniendo servicios temporalmente..."
docker-compose stop

# Crear backup
echo "Creando archivo de backup..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    --exclude="data/redis/dump.rdb.bak" \
    --exclude="data/logs/*.log" \
    data/ docker-compose.yml .env 2>/dev/null || true

# Reiniciar servicios
echo "Reiniciando servicios..."
docker-compose start

# Mostrar información del backup
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
echo "✅ Backup completado!"
echo "   Archivo: $BACKUP_DIR/$BACKUP_FILE"
echo "   Tamaño:  $BACKUP_SIZE"

# Limpiar backups antiguos (mantener solo los últimos 7)
cd "$BACKUP_DIR"
ls -t poste_backup_*.tar.gz | tail -n +8 | xargs -r rm -f
echo "🧹 Backups antiguos limpiados (manteniendo los últimos 7)"

echo "🎉 Backup completado exitosamente!"