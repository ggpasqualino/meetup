# Buider image
FROM elixir:1.5.0 as builder

ENV NODE_VERSION=7
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get -y install nodejs

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /app
ENV MIX_ENV prod
ADD . .
RUN mix deps.get --only $MIX_ENV
RUN npm install
RUN ./node_modules/brunch/bin/brunch b -p
RUN mix phoenix.digest
RUN mix release --env=$MIX_ENV

# Release image
FROM debian:jessie-slim

ENV REPLACE_OS_VARS=true\
    LANG=C.UTF-8

RUN apt-get -qq update
RUN apt-get -qq install libssl1.0.0 libssl-dev
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/meetup .

CMD ["./bin/meetup", "foreground"]
