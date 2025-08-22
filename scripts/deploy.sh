#!/bin/bash
set -e

echo "🚀 Iniciando deploy de Poste.io..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    error "Docker no está instalado. Instálalo primero."
fi

if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose no está instalado. Instálalo primero."
fi

# Verificar que el archivo docker-compose.yml existe
if [[ ! -f "docker-compose.yml" ]]; then
    error "No se encontró docker-compose.yml en el directorio actual."
fi

# Verificar configuración del hostname
hostname_in_compose=$(grep "hostname:" docker-compose.yml | head -1 | sed 's/.*hostname: //' | sed 's/ .*//')
if [[ "$hostname_in_compose" == "mail.ejemplo.com" ]]; then
    warn "⚠️  IMPORTANTE: Aún tienes el hostname de ejemplo (mail.ejemplo.com)"
    warn "   Edita docker-compose.yml y cambia 'hostname: mail.ejemplo.com' por tu dominio real"
    read -p "¿Quieres continuar de todas formas? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Crear directorio de datos si no existe
if [[ ! -d "data" ]]; then
    log "Creando directorio de datos..."
    mkdir -p data
fi

# Verificar puertos
log "Verificando puertos 8080 y 8443..."
if netstat -tuln 2>/dev/null | grep -q ":8080 "; then
    warn "El puerto 8080 parece estar en uso"
fi

if netstat -tuln 2>/dev/null | grep -q ":8443 "; then
    warn "El puerto 8443 parece estar en uso"
fi

# Construir imagen
log "Construyendo imagen Docker..."
docker-compose build

# Iniciar servicios
log "Iniciando servicios..."
docker-compose up -d

# Esperar a que el servicio esté listo
log "Esperando a que el servicio esté listo..."
sleep 10

# Verificar que el contenedor esté corriendo
if docker-compose ps | grep -q "Up"; then
    log "✅ Servicio iniciado correctamente!"
    echo
    echo "🌐 Accesos:"
    echo "   Web Interface: https://$hostname_in_compose:8443"
    echo "   Admin Setup:   https://$hostname_in_compose:8443/admin/install/server"
    echo
    echo "📧 Puertos de correo:"
    echo "   SMTP:     25"
    echo "   Secure:   587 (TLS), 465 (SSL)"
    echo "   IMAP:     143 (TLS), 993 (SSL)"
    echo "   POP3:     110 (TLS), 995 (SSL)"
    echo
    echo "📋 Comandos útiles:"
    echo "   Ver logs:     docker-compose logs -f"
    echo "   Reiniciar:    docker-compose restart"
    echo "   Parar:        docker-compose down"
    echo
else
    error "❌ Error al iniciar el servicio. Revisa los logs con: docker-compose logs"
fi

log "Deploy completado! 🎉"