FROM nginx:alpine

# Copier la page HTML
COPY index.html /usr/share/nginx/html/

# Configuration Nginx simple
RUN echo 'server { \
    listen 3000; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ =404; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Changer le port d'écoute de nginx
RUN sed -i 's/listen       80;/listen       3000;/' /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
