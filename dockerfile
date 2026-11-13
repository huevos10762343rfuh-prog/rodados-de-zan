
FROM php:8.2-apache

# Instalar MariaDB y extensiones de PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && rm -rf /var/lib/apt/lists/*

# Configuración predeterminada
ENV DB_NAME=autos
ENV DB_USER=usuario_php
ENV DB_PASSWORD=cambiame

WORKDIR /var/www/html

# Copiar el proyecto
COPY . /var/www/html/

# Preparar archivos y directorios
RUN mkdir -p /database /run/mysqld /var/lib/mysql \
    && mv /var/www/html/autos.sql /database/autos.sql \
    && mv /var/www/html/start.sh /start.sh \
    && mv /var/www/html/migrar_passwords.php /migrar_passwords.php \
    && rm -f /var/www/html/dockerfile \
    && sed -i 's/\r$//' /start.sh \
    && chmod +x /start.sh

EXPOSE 10000

CMD ["/bin/bash", "/start.sh"]
