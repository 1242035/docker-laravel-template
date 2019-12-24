FROM php:7.2-fpm

COPY ./spotech-backend/ /var/www

WORKDIR /var/www

RUN apt-get update -y && apt-get install -y cron wget nginx supervisor zip unzip curl build-essential libssl-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring zip

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

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
