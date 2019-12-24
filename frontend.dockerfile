FROM node:10

COPY ./spotech-frontend/ /var/www

WORKDIR /var/www

RUN apt-get update -y && apt-get install -y supervisor

COPY ./docker/supervisord.d/conf.d/supervisord.node.conf /etc/supervisor/conf.d/supervisord.conf
RUN npm install
RUN npm run build

EXPOSE 3000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
