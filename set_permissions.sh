#!/bin/bash
# filepath: d:\Juegos\dnd\cauldron\set_permissions.sh

# Configura los permisos para los directorios y archivos necesarios
echo "Setting permissions for /var/www/html/public/files and /var/www/html/public/resources..."
chown -R www-data:www-data /var/www/html/public/files /var/www/html/public/resources
chmod -R 775 /var/www/html/public/files /var/www/html/public/resources

echo "Permissions set successfully."