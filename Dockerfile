FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/
COPY quest-data.json /usr/share/nginx/html/
COPY logo.svg /usr/share/nginx/html/
COPY logo.png /usr/share/nginx/html/
COPY og-image.png /usr/share/nginx/html/
COPY demo.html /usr/share/nginx/html/
COPY privacy.html /usr/share/nginx/html/
COPY tos.html /usr/share/nginx/html/

EXPOSE 8080
