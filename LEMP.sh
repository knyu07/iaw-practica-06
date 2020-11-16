#!/bin/bash
set -x

# Actualizamos la lista de paquetes
apt update

#Actualizamos los paquete
apt upgrade -y 

#Instalación NGINX
apt-get install nginx -y

# Instalamos el MySQL Server
apt install mysql-server -y

# Definimos la contraseña root de MySQL
BD_ROOT_PASSWD=root

# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$BD_ROOT_PASSWD';"
mysql -u root <<< "FLUSH PRIVILEGES;"

# Instalamos los módulos de PHP
apt-get install php-fpm php-mysql

#Configuración de php-fpm
nano /etc/php/7.4/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini

#Reiniciamos
systemctl restart php7.4-fpm

#Configuramos NGNIX para usar php.fpm
nano /etc/nginx/sites-available/default
sed -i "s/index/index.php/" /etc/nginx/sites-available/default




########################################
#    HERRAMIENTAS ADMINISTRATIVAS
########################################

# INSTALACIÓN DE PHPMYADMIN

# Configuramos la contraseña para phpMyAdmin en MySQL
PHPMYADMIN_PASSWD=phpmyadmin

# Configuramos las opciones de instalación de phpMyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-password-confirm password $PHPMYADMIN_PASSWD" | debconf-set-selections

# Instalamos phpMyAdmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# INSTALACIÓN GOACCESS

echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
apt-get update -y
apt-get install goaccess -y

#Creación de un direcctorio para consultar estadísticas
# DEFINIMOS VARIABLES
HTTPPASSWD_USER=usuario
HTTPASSWD_PASSWD=contraseña
HTTPPASSWD_DIR=/home/ubuntu

mkdir -p /var/www/html/stats
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -bc $HTTPPASSWD_DIR/.htpasswd $HTTPPASSWD_USER $HTTPASSWD_PASSWD

# Copiamos el archivo de configuración de Apache
git clone https://github.com/knyu07/iaw-practica-06
cp /home/ubuntu/iaw-practica_06/000-default.conf /etc/apache2/sites-available/
systemctl restart apache2

# --------------------------------------------------------------------------------
# Instalamos la aplicación web
# --------------------------------------------------------------------------------

# Clonamos el repositorio
cd /var/www/html
rm -rf iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp
mv /var/www/html/iaw-practica-lamp/src/* /var/www/html/
# Importamos el script de creación de la base de datos
mysql -u root -p$BD_ROOT_PASSWD  < /var/www/html/iaw-practica-lamp/db/database.sql

# Eliminamos contenido que no sea útil
rm -rf /var/www/html/index.html 
rm -rf /var/www/html/iaw-practica-lamp

#Cambiamos los permisos
chown www-data:www-data * -R
