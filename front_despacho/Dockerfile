# Etapa 1: Construcción (Build Stage)
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Etapa 2: Producción (Production Stage)
FROM nginx:alpine
# Copiar el build generado por Vite
COPY --from=build /app/dist /usr/share/nginx/html

# Configuración de permisos para cumplir con "Usuario no root"
RUN touch /var/run/nginx.pid && \
  chown -R nginx:nginx /var/run/nginx.pid && \
  chown -R nginx:nginx /var/cache/nginx && \
  chown -R nginx:nginx /usr/share/nginx/html

USER nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]