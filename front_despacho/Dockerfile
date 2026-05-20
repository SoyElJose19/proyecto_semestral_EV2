# Etapa 1: Construcción
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Etapa 2: Servidor Web
FROM nginx:alpine
# Añade esta línea para copiar la configuración de Nginx:
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos la build de Vite
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]