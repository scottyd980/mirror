FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
  curl locales aptitude git wget build-essential automake \
  autoconf m4 nginx
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TERM=linux

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
  dpkg -i erlang-solutions_1.0_all.deb && \
  apt-get update && \
  apt-get install -y \
    esl-erlang=1:21.0

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get

CMD MIX_ENV=prod mix release --env=prod