FROM 'elixir:latest'

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get

RUN MIX_ENV=prod mix release