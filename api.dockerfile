FROM php:7.3-fpm

COPY ./spotech-backend/ /var/www

WORKDIR /var/www

RUN apt-get update && apt-get purge --auto-remove -y && apt-get upgrade -y && apt-get install -y cron wget zip unzip nginx supervisor libonig-dev libxml2-dev libmcrypt-dev openssl libssl-dev libcurl4-openssl-dev

RUN docker-php-ext-install pdo
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pdo_mysql 
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install gettext
RUN docker-php-ext-install iconv
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install ctype
RUN docker-php-ext-install json
RUN docker-php-ext-install tokenizer
RUN docker-php-ext-install xml
# idk bz2 enchant 
#RUN apt install -y libbz2-dev
#RUN docker-php-ext-install bz2

#RUN docker-php-ext-install timezonedb

# install apcu
RUN pecl install apcu \
    && docker-php-ext-enable apcu

#install Imagemagick & PHP Imagick ext
RUN apt-get update && apt-get install -y \
        libmagickwand-dev --no-install-recommends

RUN pecl install imagick-3.4.4 && docker-php-ext-enable imagick

# install mongodb ext
RUN pecl install mongodb-1.6.1 && docker-php-ext-enable mongodb

RUN mkdir /run/php

COPY ./docker/nginx/conf.d/api.spotech.io.conf /etc/nginx/sites-available/default
COPY ./docker/supervisord.d/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY  ./docker/cron.d/spotech-schedule.txt /etc/cron.d/spotech-schedule

RUN wget https://getcomposer.org/composer-stable.phar

RUN mv composer-stable.phar /usr/local/bin/composer

RUN chmod +x /usr/local/bin/composer
RUN composer install

RUN chmod -R 777 /var/www/storage \
        /var/www/bootstrap/cache \
        /run/php

RUN php artisan key:generate
RUN php artisan config:clear
RUN php artisan passport:install
RUN php artisan config:cache
RUN php artisan optimize

EXPOSE 80 6001

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
