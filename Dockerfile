FROM node:16.13.0-alpine3.11 as builder

RUN apk add --no-cache git
RUN git clone --depth=1 -b v1.0.0 https://github.com/microsoft/BotFramework-Composer.git /app

WORKDIR /app/Composer

RUN yarn install

ENV NODE_ENV "production"

RUN yarn build:prod

RUN cd /app && \
    find . \( \
      -path './Composer' -o \
      -path './Composer/*' -o \
      -path './runtime' -o \
      -path './runtime/*' \
    \) -prune -o -mindepth 1 -delete

RUN find . \( \
      -path './yarn.lock' -o \
      -path './package.json' -o \
      -path './packages' -o \
      -path './packages/client' -o \
      -path './packages/client/*' -o \
      -path './packages/electron-server' -o \
      -path './packages/electron-server/*' -o \
      -path './packages/extensions' -o \
      -path './packages/extensions/*' -o \
      -path './packages/lib' -o \
      -path './packages/lib/*' -o \
      -path './packages/server' -o \
      -path './packages/server/*' -o \
      -path './packages/tools' -o \
      -path './packages/tools/*' -o \
      -path './packages/ui-plugins' -o \
      -path './packages/ui-plugins/*' -o \
      -path './plugins' -o \
      -path './plugins/*' \
    \) -prune -o -mindepth 1 -delete

FROM mcr.microsoft.com/dotnet/core/sdk:3.1.301-alpine3.11

COPY --from=builder /app /app

WORKDIR /app/Composer

ENV NODE_ENV "production"

RUN apk add --no-cache yarn \
    && yarn \
    && yarn cache clean

CMD ["yarn", "start"]
