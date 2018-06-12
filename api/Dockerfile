FROM 'elixir:latest'

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get

CMD MIX_ENV=prod mix release