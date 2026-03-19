FROM node:20-alpine as build

WORKDIR /app

COPY Web/ui/package*.json ./
RUN npm install

COPY Web/ui/ .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

RUN printf 'events {\n\
    worker_connections 1024;\n\
}\n\
\n\
http {\n\
    include /etc/nginx/mime.types;\n\
    default_type application/octet-stream;\n\
\n\
    server {\n\
        listen 80;\n\
        server_name localhost;\n\
\n\
        location / {\n\
            root /usr/share/nginx/html;\n\
            index index.html index.htm;\n\
            try_files $uri $uri/ /index.html;\n\
        }\n\
\n\
        location /api/ {\n\
            proxy_pass http://backend.railway.internal:5001/api/;\n\
            proxy_set_header Host $host;\n\
            proxy_set_header X-Real-IP $remote_addr;\n\
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
            proxy_set_header X-Forwarded-Proto $scheme;\n\
        }\n\
    }\n\
}\n' > /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
