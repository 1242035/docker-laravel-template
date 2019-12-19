FROM node:10

# Create app directory
WORKDIR /var/www/spotech/frontend

COPY ./ .

#COPY config
RUN mv config/env/production.js.example config/env/production.js
RUN mv config/env/development.js.example config/env/development.js
RUN mv secret/index.js.example secret/index.js

RUN npm install
# If you are building your code for production
RUN npm ci
RUN npm run build

# Bundle app source

EXPOSE 3112
CMD [ "nuxt", "run start" ]