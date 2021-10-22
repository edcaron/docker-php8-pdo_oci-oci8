FROM ubuntu
MAINTAINER eduardo <eduardocaron10@gmail.com>
ADD ./files /files_aux

RUN apt-get update --fix-missing

RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get install apache2 -y && \
apt-get install software-properties-common -y && \
add-apt-repository ppa:ondrej/php -y && \
apt-get install -y tzdata && \
ln -sf /usr/share/zoneinfo/America/Fortaleza /etc/localtime   && \
dpkg-reconfigure --frontend noninteractive tzdata  && \
apt-get update --fix-missing && \
apt-get install -y php7.3 php7.3-xml php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline libapache2-mod-php7.3 php-pear php7.3-dev php7.3-pgsql php7.3-mysql && \
apt-get install -y php7.3-bcmath php7.3-calendar php7.3-cgi  php7.3-ctype  php7.3-dom php7.3-exif php7.3-fileinfo php7.3-ftp php7.3-gettext php7.3-iconv php7.3-imap php7.3-mbstring php7.3-mysqli  && \
apt-get install -y php7.3-mysqlnd php7.3-pdo php7.3-pdo-mysql php7.3-pdo-pgsql php7.3-phar php7.3-posix php7.3-shmop php7.3-simplexml php7.3-sockets php7.3-sysvmsg php7.3-sysvsem php7.3-sysvshm && \
apt-get install -y php7.3-tokenizer php7.3-wddx php7.3-xmlreader php7.3-xmlwriter php7.3-xsl php7.3-zip && \
apt-get install -y libaio1  && \
apt-get install -y alien && \
alien -i /files_aux/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm  && \
alien -i /files_aux/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm  && \
alien -i /files_aux/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm  && \
echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf  && \
ldconfig  && \
export ORACLE_HOME=/usr/lib/oracle/11.2/client64/   && \
cd /files_aux/php-src-PHP-7.3.5/ext/oci8/  && \
phpize  && \
./configure --with-oci8=instantclient,/usr/lib/oracle/11.2/client64/lib  && \
make install  && \
echo "extension=oci8.so" > /etc/php/7.3/mods-available/oci8.ini   && \
ln -s /etc/php/7.3/mods-available/oci8.ini /etc/php/7.3/apache2/conf.d/oci8.ini  && \
ln -s /etc/php/7.3/mods-available/oci8.ini /etc/php/7.3/cli/conf.d/oci8.ini  && \
cd /files_aux/php-src-PHP-7.3.5/ext/pdo_oci/  && \
phpize  && \
./configure --with-pdo-oci=instantclient,/usr/lib/oracle/11.2/client64/lib  && \
make install  && \
echo "extension=pdo_oci.so" > /etc/php/7.3/mods-available/pdo_oci.ini  && \
ln -s /etc/php/7.3/mods-available/pdo_oci.ini /etc/php/7.3/apache2/conf.d/pdo_oci.ini && \
ln -s /etc/php/7.3/mods-available/pdo_oci.ini /etc/php/7.3/cli/conf.d/pdo_oci.ini

RUN apt-get install php7.3-curl -y
RUN apt-get install php-sqlite3 -y
RUN apt-get install php7.3-sqlite3 -y
RUN apt-get install php-apcu php7.3-apcu -y
RUN apt-get install php7.3-gd -y

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

#RUN apt-get install -y postgresql

RUN apt-get install -y php7.3-xdebug
RUN apt-get install -y vim
RUN sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.3/apache2/php.ini

#xdebug setting for apache
RUN echo -e -n "\n\nxdebug.mode=debug,develop \nxdebug.remote_handler=dbgp \nxdebug.start_with_request=yes \nxdebug.client_port=9003 \nxdebug.discover_client_host=yes \nxdebug.idekey=docker \n#xdebug.log=/var/www/html/xdebug.log \n#xdebug.log_level=10 \n#xdebug.client_host=host.docker.internal" >> /etc/php/7.3/apache2/php.ini

#xdebug setting for cli
RUN echo -e -n "\n\nxdebug.mode=debug,develop,coverage \nxdebug.remote_handler=dbgp \nxdebug.start_with_request=yes \nxdebug.client_port=9003 \nxdebug.discover_client_host=yes \nxdebug.idekey=docker \n#xdebug.log=/var/www/html/xdebug.log \n#xdebug.log_level=10 \n#xdebug.client_host=host.docker.internal" >> /etc/php/7.3/cli/php.ini

RUN pecl install mongodb

RUN echo 'extension=mongodb.so' >> /etc/php/7.3/apache2/php.ini
RUN echo 'extension=mongodb.so' >> /etc/php/7.3/mods-available/mongodb.ini
RUN phpenmod mongodb
RUN service apache2 restart

#RUN chmod -R 777 /var/www/html
RUN ln -sf /dev/stderr /var/log/apache2/error.log
RUN rm -rf /files_aux
WORKDIR /var/www/html/
EXPOSE 80 9003
CMD apachectl -D FOREGROUND
