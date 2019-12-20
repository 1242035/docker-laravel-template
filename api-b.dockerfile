FROM ubuntu:latest

COPY ./spotech-backend/ /var/www

WORKDIR /var/www

RUN apt-get update -y && apt-get install -y cron wget zip vim unzip nginx supervisor php7.2 php7.2-common php7.2-fpm php7.2-cli php7.2-gd php7.2-mysql php7.2-curl php7.2-intl php7.2-mbstring php7.2-bcmath php7.2-imap php7.2-xml php7.2-zip

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
