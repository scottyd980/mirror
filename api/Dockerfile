# Dockerfile
FROM elixir:1.6.5-alpine as build

# install build dependencies
RUN apk add --update git
RUN apk add --update make
RUN apk add --update g++

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod REPLACE_OS_VARS=true

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get
COPY config ./
RUN mix deps.compile

# build release
COPY . .
RUN mix release --no-tar --verbose --env=prod

# prepare release image
FROM alpine:3.6
RUN apk add --update bash openssl

WORKDIR /app

# ENV PORT=4000 DB_HOST="68.183.98.121" USERNAME="admin" PASSWORD="35764652727ab62770b9295cfb80f2bfd5fbec0bb0303efa" DATABASE="mirror_new_prod" SECRET_KEY_BASE="PaiowhrbZBKyE5NxFlvy1tpJ03BvK9jS9IHhoOXfxQ7wbU7VX/cDJLJbPlnjtVeK"

COPY --from=build /app/_build/prod/rel/mirror ./

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/bash

ENTRYPOINT ["/app/bin/mirror"]