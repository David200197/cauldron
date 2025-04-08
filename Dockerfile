# Usa una imagen base de PHP con Apache
FROM php:7.4-apache

# Instala las extensiones necesarias para PHP y herramientas de compilación
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

# Configura la zona horaria
RUN echo "date.timezone=America/Mexico_City" > /usr/local/etc/php/conf.d/timezone.ini

# Habilita mod_rewrite para Apache (necesario para URL rewriting)
RUN a2enmod rewrite

# Copia los archivos del proyecto al contenedor
COPY . /var/www/html

# Copia el script de permisos al contenedor
COPY set_permissions.sh /usr/local/bin/set_permissions.sh

# Asegúrate de que el script sea ejecutable
RUN chmod +x /usr/local/bin/set_permissions.sh

# Asegúrate de que los directorios necesarios existan antes de cambiar permisos
RUN mkdir -p /var/www/html/public/files /var/www/html/public/resources

# Descomprime y compila el servidor WebSocket cauldrond
WORKDIR /var/www/html/extra
RUN tar -xzf cauldrond.tar.gz && \
    cd cauldrond && \
    cmake . && \
    make && \
    cp cauldrond /usr/sbin/ && \
    cp conf/cauldrond /etc/init.d/ && \
    chmod +x /etc/init.d/cauldrond

# Configura el puerto del WebSocket en el archivo de configuración
RUN sed -i 's/WEBSOCKET_PORT=.*/WEBSOCKET_PORT=2001/' /var/www/html/settings/cauldron.conf

# Expone los puertos necesarios
EXPOSE 80 2001

# Comando para iniciar Apache, el servidor WebSocket y configurar permisos
CMD /usr/local/bin/set_permissions.sh && service cauldrond start && apache2-foreground