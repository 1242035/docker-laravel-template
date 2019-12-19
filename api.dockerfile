FROM ubuntu:latest

COPY ./spotech-api/ /var/www

WORKDIR /var/www

RUN apt-get update -y && apt-get install -y cron wget zip unzip nginx supervisor php7.2 php7.2-common php7.2-fpm php7.2-cli php7.2-gd php7.2-mysql php7.2-curl php7.2-intl php7.2-mbstring php7.2-bcmath php7.2-imap php7.2-xml php7.2-zip

COPY ./docker/nginx/conf.d/ /etc/nginx/site-avaiable/default
COPY ./docker/supervisord.d/conf.d/ /etc/supervisor/conf.d/
COPY  ./docker/cron.d/spotech-schedule.txt /etc/cron.d/spotech-schedule

RUN wget https://getcomposer.org/download/1.9.1/composer.phar

RUN mv composer.phar /usr/local/bin/composer


RUN chmod +x /usr/local/bin/composer
RUN composer install
RUN chmod -R 777 /var/www/storage \
        /var/www/bootstrap/cache

RUN php artisan key:generate
RUN php artisan config:clear
RUN php artisan config:cache
RUN php artisan optimize
RUN php artisan passport:install

EXPOSE 80

CMD ["/usr/bin/supervisord"]

ENTRYPOINT supervisorctl start all && /bin/bash
