#!/bin/bash
set -x

# Actualizamos la lista de paquetes
apt update

#Actualizamos los paquete
apt upgrade -y 

#Instalación NGINX
sudo apt-get install nginx -y

# Instalamos el MySQL Server
apt install mysql-server -y

# Definimos la contraseña root de MySQL
BD_ROOT_PASSWD=root

# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$BD_ROOT_PASSWD';"
mysql -u root <<< "FLUSH PRIVILEGES;"

# Instalamos los módulos de PHP
apt-get install php-fpm php-mysql -y

#Configuración de php-fpm
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini

#Reiniciamos
systemctl restart php7.4-fpm

#Renombramos y movemos
mv /var/www/html/index.nginx-debian.html nginx.html
mv nginx.html /var/www/html

#Configuramos NGINX para usar php.fpm
cd /home/ubuntu
cp /home/ubuntu/iaw-practica-06/default /etc/nginx/sites-available/default
cp /home/ubuntu/iaw-practica-06/info.php /var/www/html
systemctl restart nginx


########################################
#    HERRAMIENTAS ADMINISTRATIVAS
########################################

#-------------- Herramientas Administrativas -----------------------#

# INSTALACIÓN ADMINER
# Creamos carpeta
sudo mkdir /var/www/html/Adminer
# Nos movemos a esta ruta
cd /var/www/html/Adminer

# Instalamos herramientas adicionales
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php

# Renombrar el archivo Adminer
mv adminer-4.7.7-mysql.php index.php

# INSTALACIÓN DE PHPMYADMIN
apt install unzip -y

#Descargamos el código fuente de phpMyAdmin
cd /home/Ubuntu
rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip

#Descomprimimos el archivo .zip
unzip phpMyAdmin-5.0.4-all-languages.zip

#Borramos el archivo .zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip

#Movemos el directorio de phpMyAdmin al directorio /var/www/html
mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin


# --------------------------------------------------------------------------------
# Instalamos la aplicación web
# --------------------------------------------------------------------------------

# Clonamos el repositorio
cd /var/www/html
rm -rf iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp
mv /var/www/html/iaw-practica-lamp/src/* /var/www/html/

# Eliminamos contenido que no sea útil
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp

#Cambiamos los permisos
chown www-data:www-data * -R

#Reiniciamos
systemctl restart nginx
