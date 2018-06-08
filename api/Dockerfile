FROM 'elixir:latest'

COPY ./api .

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get

RUN mix edeliver build release production --verbose