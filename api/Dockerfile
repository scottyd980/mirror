# ./Dockerfile

# # Starting from the official Elixir 1.3.2 image:
# # https://hub.docker.com/_/elixir/
# FROM elixir:latest

# # # RUN apt-get update && \
# # #     apt-get install -y mysql-server

# # ENV MYSQL_USER=mysql \
# #     MYSQL_DATA_DIR=/var/lib/mysql \
# #     MYSQL_RUN_DIR=/run/mysqld \
# #     MYSQL_LOG_DIR=/var/log/mysql

# # RUN apt-get update \
# #  && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
# #  && rm -rf ${MYSQL_DATA_DIR} \
# #  && rm -rf /var/lib/apt/lists/*

# # # Install hex
# # RUN mix local.hex --force

# # # Install rebar
# # RUN mix local.rebar --force

# # # Install the Phoenix framework itself
# # RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# # # Set /app as workdir
# # WORKDIR /app

# # install hex package manager
# RUN mix local.hex --force

# # install phoenix
# RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

# # create app folder
# RUN mkdir /app  
# COPY . /app  
# WORKDIR /app

# # setting the port and the environment (prod = PRODUCTION!)
# #ENV MIX_ENV=prod  
# ENV PORT=4000

# # install dependencies (production only)
# RUN mix local.rebar --force  
# RUN mix deps.get
# RUN mix compile

# run phoenix in production on PORT 4000
# CMD mix phx.server

# Versions
#
# Erlang: 1:20.2.2
# Elixir: 1.6.1
# Phoenix: 1.3.0

FROM ubuntu:17.10

ENV DEBIAN_FRONTEND noninteractive

# Elixir requires UTF-8
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y sudo wget curl inotify-tools git build-essential zip unzip

# Download and install nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - && apt-get install -y nodejs

# Download and install Erlang package
RUN wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
  && dpkg -i erlang-solutions_1.0_all.deb \
  && apt-get update

ENV ERLANG_VERSION 1:20.2.2

# Install Erlang
RUN apt-get install -y esl-erlang=$ERLANG_VERSION && rm erlang-solutions_1.0_all.deb

ENV ELIXIR_VERSION 1.6.1

# Install Elixir
RUN mkdir /opt/elixir \
  && cd /opt/elixir \
  && curl -O -L https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip \
  && unzip Precompiled.zip \
  && cd /usr/local/bin \
  && ln -s /opt/elixir/bin/elixir \
  && ln -s /opt/elixir/bin/elixirc \
  && ln -s /opt/elixir/bin/iex \
  && ln -s /opt/elixir/bin/mix

ENV PHOENIX_VERSION 1.3.0

# Install the Phoenix Mix archive
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new-$PHOENIX_VERSION.ez

# Install hex & rebar
RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix hex.info

# create app folder
RUN mkdir /api  
COPY . /api
WORKDIR /api

# setting the port and the environment (prod = PRODUCTION!)
#ENV MIX_ENV=prod  
ENV PORT=4000

# install dependencies (production only)
RUN mix local.rebar --force  
RUN mix deps.get
RUN mix compile

ENV DB_PASS ${DB_PASS}