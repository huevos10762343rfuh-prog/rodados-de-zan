
#!/bin/bash

set -e

SOCK=/run/mysqld/mysqld.sock

DB_NAME="${DB_NAME:-autos}"
DB_USER="${DB_USER:-usuario_php}"
DB_PASSWORD="${DB_PASSWORD:-cambiame}"
PORT="${PORT:-10000}"

# Configurar Apache para Render
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf

sed -i "s/<VirtualHost \*:[0-9]*>/<VirtualHost *:${PORT}>/" \
    /etc/apache2/sites-available/000-default.conf

# Preparar MariaDB
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Inicializar la base de datos si todavía no existe
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Iniciar MariaDB
mariadbd \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --bind-address=127.0.0.1 \
    --socket="$SOCK" \
    --pid-file=/run/mysqld/mysqld.pid &

# Esperar a que MariaDB esté disponible
for i in {1..60}; do
    if mariadb-admin --socket="$SOCK" ping --silent; then
        break
    fi
    sleep 1
done

# Verificar que haya iniciado
mariadb-admin --socket="$SOCK" ping --silent

# Crear base de datos
mariadb --socket="$SOCK" -e "
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`
CHARACTER SET utf8mb4;
"

# Crear usuario para PHP
mariadb --socket="$SOCK" -e "
CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1'
IDENTIFIED BY '$DB_PASSWORD';

ALTER USER '$DB_USER'@'127.0.0.1'
IDENTIFIED BY '$DB_PASSWORD';

GRANT ALL PRIVILEGES ON \`$DB_NAME\`.*
TO '$DB_USER'@'127.0.0.1';

FLUSH PRIVILEGES;
"

# Importar SQL solamente la primera vez
if [ -f /database/autos.sql ] && [ ! -f /var/lib/mysql/.autos_imported ]; then

    mariadb --socket="$SOCK" "$DB_NAME" < /database/autos.sql

    touch /var/lib/mysql/.autos_imported

fi

# Convertir las contraseñas antiguas en hashes
php /migrar_passwords.php

# Iniciar Apache
exec apache2-foreground
