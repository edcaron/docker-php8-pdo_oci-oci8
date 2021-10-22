FROM ubuntu:20.04
MAINTAINER eduardo <eduardocaron10@gmail.com>
ADD ./files /files_aux

RUN apt-get clean
RUN apt-get update --fix-missing

RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get install apache2 -y && \
apt-get install software-properties-common -y && \
add-apt-repository ppa:ondrej/php -y && \
apt-get install -y tzdata && \
apt-get update --fix-missing && \
apt-get install -y php8.0 php8.0-xml php8.0-cli php8.0-common php8.0-opcache php8.0-readline libapache2-mod-php8.0 php-pear php8.0-dev php8.0-pgsql php8.0-mysql && \
apt-get install -y php8.0-bcmath php8.0-calendar php8.0-cgi  php8.0-ctype  php8.0-dom php8.0-exif php8.0-fileinfo php8.0-ftp php8.0-gettext php8.0-iconv php8.0-imap php8.0-mbstring php8.0-mysqli  && \
apt-get install -y php8.0-mysqlnd php8.0-pdo php8.0-pdo-mysql php8.0-pdo-pgsql php8.0-phar php8.0-posix php8.0-shmop php8.0-simplexml php8.0-sockets php8.0-sysvmsg php8.0-sysvsem php8.0-sysvshm && \
apt-get install -y php8.0-tokenizer php8.0-xmlreader php8.0-xmlwriter php8.0-xsl php8.0-zip && \
apt-get install -y libaio1  && \
apt-get install -y alien && \
alien -i /files_aux/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm  && \
alien -i /files_aux/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm  && \
alien -i /files_aux/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm  && \
echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf  && \
ldconfig  && \
export ORACLE_HOME=/usr/lib/oracle/11.2/client64/   && \
cd /files_aux/php-8.0.12/ext/oci8/  && \
phpize  && \
./configure --with-oci8=instantclient,/usr/lib/oracle/11.2/client64/lib  && \
make install  && \
echo "extension=oci8.so" > /etc/php/8.0/mods-available/oci8.ini   && \
ln -s /etc/php/8.0/mods-available/oci8.ini /etc/php/8.0/apache2/conf.d/oci8.ini  && \
ln -s /etc/php/8.0/mods-available/oci8.ini /etc/php/8.0/cli/conf.d/oci8.ini  && \
cd /files_aux/php-8.0.12/ext/pdo_oci/  && \
phpize  && \
./configure --with-pdo-oci=instantclient,/usr/lib/oracle/11.2/client64/lib  && \
make install  && \
echo "extension=pdo_oci.so" > /etc/php/8.0/mods-available/pdo_oci.ini  && \
ln -s /etc/php/8.0/mods-available/pdo_oci.ini /etc/php/8.0/apache2/conf.d/pdo_oci.ini && \
ln -s /etc/php/8.0/mods-available/pdo_oci.ini /etc/php/8.0/cli/conf.d/pdo_oci.ini

RUN apt-get install php8.0-curl -y
RUN apt-get install php-sqlite3 -y
RUN apt-get install php8.0-sqlite3 -y
RUN apt-get install php-apcu php8.0-apcu -y
RUN apt-get install php8.0-gd -y

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

#RUN apt-get install -y postgresql

RUN apt-get install -y php8.0-xdebug
RUN apt-get install -y vim
RUN sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/8.0/apache2/php.ini

#xdebug setting for apache
RUN echo -e -n "\n\nxdebug.mode=debug,develop \nxdebug.remote_handler=dbgp \nxdebug.start_with_request=yes \nxdebug.client_port=9003 \nxdebug.discover_client_host=yes \nxdebug.idekey=docker \n#xdebug.log=/var/www/html/xdebug.log \n#xdebug.log_level=10 \n#xdebug.client_host=host.docker.internal" >> /etc/php/8.0/apache2/php.ini

#xdebug setting for cli
RUN echo -e -n "\n\nxdebug.mode=debug,develop,coverage \nxdebug.remote_handler=dbgp \nxdebug.start_with_request=yes \nxdebug.client_port=9003 \nxdebug.discover_client_host=yes \nxdebug.idekey=docker \n#xdebug.log=/var/www/html/xdebug.log \n#xdebug.log_level=10 \n#xdebug.client_host=host.docker.internal" >> /etc/php/8.0/cli/php.ini

RUN pecl install mongodb

RUN echo 'extension=mongodb.so' >> /etc/php/8.0/apache2/php.ini
RUN echo 'extension=mongodb.so' >> /etc/php/8.0/mods-available/mongodb.ini
RUN phpenmod mongodb
RUN service apache2 restart

#RUN chmod -R 777 /var/www/html
RUN ln -sf /dev/stderr /var/log/apache2/error.log
RUN rm -rf /files_aux
WORKDIR /var/www/html/
EXPOSE 80 9003
CMD apachectl -D FOREGROUND
