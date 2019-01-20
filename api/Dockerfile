# FROM ubuntu:16.04

# RUN apt-get update && apt-get install -y \
#   curl locales aptitude git wget build-essential automake \
#   autoconf m4 nginx
# RUN locale-gen en_US.UTF-8
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8
# ENV TERM=linux

# RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
#   dpkg -i erlang-solutions_1.0_all.deb && \
#   apt-get update && \
#   apt-get install -y \
#     esl-erlang=1:20.3 && \
#   apt-get install elixir

# COPY . .

# RUN mix local.hex --force && \
#     mix local.rebar --force

# RUN export MIX_ENV=prod && \
#     rm -Rf _build && \
#     mix deps.get

# CMD MIX_ENV=prod mix release --env=prod

# Dockerfile
# FROM elixir:1.6.5-alpine as build

# # install build dependencies
# RUN apk add --update git
# RUN apk add --update make
# RUN apk add --update g++

# # prepare build dir
# RUN mkdir /app
# WORKDIR /app

# # install hex + rebar
# RUN mix local.hex --force && \
#     mix local.rebar --force

# # set build ENV
# ENV MIX_ENV=prod REPLACE_OS_VARS=true

# # install mix dependencies
# COPY mix.exs mix.lock ./
# RUN mix deps.get
# COPY config ./
# RUN mix deps.compile

# # build release
# COPY . .
# RUN mix release --no-tar --verbose --env=prod

# # prepare release image
# FROM alpine:3.6
# RUN apk add --update bash openssl

# RUN mkdir /app && chown -R nobody: /app
# WORKDIR /app
# USER nobody

# COPY --from=build /app/_build/prod/rel/mirror ./

# ENV REPLACE_OS_VARS=true
# ENV PORT=4000 BEAM_PORT=14000 ERL_EPMD_PORT=24000
# EXPOSE $PORT $BEAM_PORT $ERL_EPMD_PORT

# ENTRYPOINT ["/app/bin/mirror"]










# FROM ubuntu:16.04

# RUN apt-get update && apt-get install -y \
#   curl locales aptitude git wget build-essential automake \
#   autoconf m4 nginx
# RUN locale-gen en_US.UTF-8
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8
# ENV TERM=linux

# RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
#   dpkg -i erlang-solutions_1.0_all.deb && \
#   apt-get update && \
#   apt-get install -y \
#     esl-erlang=1:20.3 && \
#   apt-get install elixir

# COPY . .

# RUN mix local.hex --force && \
#     mix local.rebar --force

# RUN export MIX_ENV=prod && \
#     rm -Rf _build && \
#     mix deps.get

# CMD MIX_ENV=prod mix release --env=prod

# Dockerfile
# FROM elixir:1.6.5 as build
# ENV DEBIAN_FRONTEND=noninteractive
# ENV TERM=xterm

# RUN mkdir /app
# WORKDIR /app

# # Install Hex+Rebar
# RUN mix local.hex --force && \
#     mix local.rebar --force

# ENV MIX_ENV=prod REPLACE_OS_VARS=true

# # Cache elixir deps
# COPY mix.exs mix.lock ./
# RUN mix deps.get

# COPY config ./config
# RUN mix deps.compile

# COPY . .
# RUN mix release --no-tar --verbose --env=prod

# # prepare release image
# FROM elixir:1.6.5
# ENV DEBIAN_FRONTEND=noninteractive

# # RUN mkdir /app && chown -R nobody: /app
# WORKDIR /app
# # USER nobody

# EXPOSE 4000
# ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/bash

# # #

# COPY --from=build /app/_build/prod/rel/mirror ./

# ENTRYPOINT ["/app/bin/mirror"]



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

COPY --from=build /app/_build/prod/rel/mirror ./

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/bash

ENTRYPOINT ["/app/bin/mirror"]