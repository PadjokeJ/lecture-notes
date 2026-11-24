FROM node:22-slim AS builder

# install git to install plugins
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY package.json .
COPY package-lock.json* .
COPY .npmrc* .
COPY quartz/ ./quartz/
COPY quartz.lock.json* .
RUN npm install; npx quartz plugin install

COPY . .

RUN npx quartz build

FROM caddy:alpine
COPY --from=builder /usr/src/app/public /srv
COPY Caddyfile.dev /etc/caddy/Caddyfile

ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
