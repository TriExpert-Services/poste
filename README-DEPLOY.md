# Guía de Deploy - Poste.io Personalizado

## Preparación

### 1. Configurar el hostname
Edita `docker-compose.yml` y cambia `mail.ejemplo.com` por tu dominio real:

```yaml
hostname: mail.tudominio.com
```

### 2. Configurar DNS
Asegúrate de que tu dominio tenga estos registros DNS:

```
# Registro A apuntando a tu servidor
mail.tudominio.com.  IN  A  TU.IP.DEL.SERVIDOR

# Registro MX para recibir correos
tudominio.com.  IN  MX  10  mail.tudominio.com.

# Registro PTR (DNS inverso) - configúralo con tu proveedor
TU.IP.DEL.SERVIDOR  IN  PTR  mail.tudominio.com.
```

### 3. Configurar firewall
Abre los puertos necesarios:

```bash
# Puertos web personalizados
sudo ufw allow 8080/tcp   # HTTP
sudo ufw allow 8443/tcp   # HTTPS

# Puertos de correo estándar
sudo ufw allow 25/tcp     # SMTP
sudo ufw allow 587/tcp    # SMTP Submission
sudo ufw allow 465/tcp    # SMTPS
sudo ufw allow 993/tcp    # IMAPS
sudo ufw allow 995/tcp    # POP3S
sudo ufw allow 110/tcp    # POP3
sudo ufw allow 143/tcp    # IMAP
sudo ufw allow 4190/tcp   # ManageSieve
```

## Deploy

### 1. Construir y ejecutar
```bash
# Construir la imagen
docker-compose build

# Iniciar el servicio
docker-compose up -d

# Ver logs
docker-compose logs -f
```

### 2. Acceso inicial
- Interfaz web: https://mail.tudominio.com:8443
- Admin: https://mail.tudominio.com:8443/admin/install/server

### 3. Configuración inicial
1. Accede a la interfaz de administración
2. Configura el certificado SSL (Let's Encrypt recomendado)
3. Crea tu primer dominio de correo
4. Crea cuentas de usuario

## Características Especiales

### Gestión de IPs Múltiples
Este build permite:
- Escuchar solo en IPs específicas
- Usar diferentes IPs para envío por dominio
- Ejecutar múltiples instancias en el mismo servidor

### Plugins de Roundcube
- Coloca plugins en `./data/roundcube-plugins/`
- Se instalan automáticamente al reiniciar

### Configuración Avanzada de IPs
Crea `./data/outbound-hosts.yml`:

```yaml
default:
  helo: mail.tudominio.com
  ip: 1.2.3.4

otrdominio.com:
  helo: mail.otrodominio.com
  ip: 5.6.7.8
```

## Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar servicio
docker-compose restart

# Actualizar imagen
docker-compose pull && docker-compose up -d

# Backup
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# Entrar al contenedor
docker-compose exec poste bash
```

## Troubleshooting

### Problema: No puedo acceder por HTTPS
- Verifica que el puerto 8443 esté abierto
- Revisa los logs: `docker-compose logs -f`
- Asegúrate de que el DNS esté configurado correctamente

### Problema: Los correos no llegan
- Verifica los registros MX
- Revisa que el puerto 25 esté abierto
- Comprueba el DNS inverso (PTR)

### Problema: Los correos van a spam
- Configura SPF: `v=spf1 mx -all`
- Configura DKIM (disponible en la interfaz admin)
- Configura DMARC: `v=DMARC1; p=quarantine;`