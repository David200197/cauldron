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
RUN a2enmod rewrite

# Crea los directorios necesarios primero
RUN mkdir -p /var/www/html/public/files /var/www/html/public/resources

# Copia los archivos del proyecto
COPY . /var/www/html/

# Establece los permisos directamente en el Dockerfile
RUN chown -R www-data:www-data /var/www/html/public/files /var/www/html/public/resources \
    && chmod -R 775 /var/www/html/public/files /var/www/html/public/resources

WORKDIR /var/www/html/extra
RUN tar -xzf cauldrond.tar.gz && \
    cd cauldrond && \
    cmake . && \
    make && \
    cp cauldrond /usr/sbin/ && \
    cp conf/cauldrond /etc/init.d/ && \
    chmod +x /etc/init.d/cauldrond

RUN sed -i 's/WEBSOCKET_PORT=.*/WEBSOCKET_PORT=2001/' /var/www/html/settings/cauldron.conf

EXPOSE 80 2001

# Modifica el CMD para asegurarse de que los permisos se mantienen
CMD chown -R www-data:www-data /var/www/html/public/files /var/www/html/public/resources \
    && chmod -R 775 /var/www/html/public/files /var/www/html/public/resources \
    && service cauldrond start \
    && apache2-foreground