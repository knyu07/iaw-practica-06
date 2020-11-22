# LA PILA LEMP
 Para está práctica instalaremos la pila LEMP en un ubuntu, lo que sería:

 - L - Linux
 - E - Nginx
 - M - MySQL
 - P - PHP

## Pasos a seguir para instalar nuestro:

![](Imágenes/nginx.png)

## Instalación

- sudo apt install nginx
  
Seguidamente instalamos el paquete php-fpm (*PHP FastCGI Process Manager*), ideal ya que permite mejorar el consumo de memoria del servidor y se ejecuta como un servicio independiente de Nginx, este se comunicará con php-fpm a través de un socket UNIX o un socket TCP/IP para revcibir la respuesta del código PHP.

- sudo apt install php-fpm

Y por último instalaremos un paquete que permite a PHP interaccionar con el sistema gestor de bases de datos MySQL

- sudo apt install php-mysql

Ahora configuraremos el archivo php-fpm para que Nginx pueda comunicarse desde un socket UNIX:

Dentro del archivo:

> - sudo nano /etc/nginx/sites-available/default

## Esta es la manera de hacerlo con el socket UNIX

En ella tendremos que hacer unos cambios, como:
-  Añadir el archivo index.php en primer lugar para darle prioridad
-  Añadimos el bloque location ~ \.php$ indicando dónde se encuentra el archivo de configuración fastcgi-php.conf y el archivo php7.2-fpm.sock
-  Y por último pero esta de manera opcional 
-  añadir el bloque location ~ /\.ht para no permitir que un usuario pueda descargar los archivos .htaccess. Estos archivos no son procesados por Nginx, son específicos de Apache

Por lo que debería quedar el archivo así:

```

server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        location ~ /\.ht {
                deny all;
        }
}

```



## Con el socker TCP/IP hacemos: 

Tendremos que cambiar la directiva listen en el archivo 

> - /etc/php.7.4/fpm/pool.d/www.conf

Y para cambiarlo usamos: 

- sed -i "s/listen = /run/php/php7.4-fpm.sock
/listen = 127.0.0.1:9000/" /etc/php/7.4/fpm/php.ini

Reiniciamos el php7.4-fpm

- sudo systemctl restart php7.4-fpm

Y para terminar configurarémos el archivo default del sites-availables:

> - /etc/nginx/sites-available/default

Y modificarémos para que quedé así: 

```
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                # With php-cgi (or other tcp sockets):
                fastcgi_pass 127.0.0.1:9000;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        location ~ /\.ht {
                deny all;
        }
}

```

Comprobamos que la sintaxis del archivo este bien usando el comando: 

- sudo nginx -t 

Y finalmente reiniciamos para que se apliquen los cambios

- sudo systemctl restart nginx

:smilecat:
