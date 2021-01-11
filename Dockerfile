ARG ALPINE_VERSION=3.12
ARG NODE_VERSION=15
ARG NGINX_VERSION=1.19.6

# multistage - builder image
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder
WORKDIR /app/Lightspeed-react
# Layer caching for node modules
COPY package.json package-lock.json ./
RUN npm install
COPY . .

# build it
RUN npm run build

# runtime image
FROM nginx:${NGINX_VERSION}-alpine
ENV WEBSOCKET_HOST=localhost
ENV WEBSOCKET_PORT=8080

COPY docker/entrypoint.sh /docker-entrypoint.d/entrypoint.sh
COPY docker/config.json.template /config.json.template
COPY --from=builder /app/Lightspeed-react/build /usr/share/nginx/html
