FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libxslt1-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    cmake \
    build-essential \
    unzip \
    && docker-php-ext-install mysqli gd xsl

RUN echo "date.timezone=America/Mexico_City" > /usr/local/etc/php/conf.d/timezone.ini

# Habilitar módulos de Apache necesarios
RUN a2enmod rewrite ssl
RUN a2ensite default-ssl

# Crear directorio SSL y generar certificado autofirmado
RUN mkdir -p /etc/apache2/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache.key \
    -out /etc/apache2/ssl/apache.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Configurar VirtualHost para SSL
RUN sed -i 's/SSLCertificateFile.*$/SSLCertificateFile \/etc\/apache2\/ssl\/apache.crt/' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i 's/SSLCertificateKeyFile.*$/SSLCertificateKeyFile \/etc\/apache2\/ssl\/apache.key/' /etc/apache2/sites-available/default-ssl.conf

# Crea los directorios necesarios
RUN mkdir -p /var/www/html/public/files /var/www/html/public/resources

# Copia los archivos del proyecto
COPY . /var/www/html/

# Establece los permisos
RUN chown -R www-data:www-data /var/www/html/public/files /var/www/html/public/resources \
    && chmod -R 775 /var/www/html/public/files /var/www/html/public/resources

# Configura el websocket
WORKDIR /var/www/html/extra
RUN tar -xzf cauldrond.tar.gz && \
    cd cauldrond && \
    cmake . && \
    make && \
    cp cauldrond /usr/sbin/ && \
    cp conf/cauldrond /etc/init.d/ && \
    chmod +x /etc/init.d/cauldrond

RUN sed -i 's/WEBSOCKET_PORT=.*/WEBSOCKET_PORT=2001/' /var/www/html/settings/cauldron.conf

EXPOSE 443 2001

# Script de inicio
CMD chown -R www-data:www-data /var/www/html/public/files /var/www/html/public/resources \
    && chmod -R 775 /var/www/html/public/files /var/www/html/public/resources \
    && service cauldrond start \
    && apache2-foreground