# docker-laravel-template

1. STRUCT
project
       docker/
       spotech-backend/
       .dockerignore
       docker-compose.yml
       api.dockerfile
       
 2.run with docker-compose: "docker-compose up --build"
 3. build image with docker: "docker build -f api.dockerfile ."
 4. run an image by docker "docker run -i -t `image_id` /bin/bash"
