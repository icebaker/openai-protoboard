FROM ruby:3.2.1-slim-bullseye AS builder-gems
RUN apt-get update && apt-get install -y --no-install-recommends git build-essential shared-mime-info
RUN bundle config set --local without 'development:test'
ADD ./api/Gemfile /build/shared/Gemfile
WORKDIR /build/shared
RUN bundle install

FROM ruby:3.2.1-slim-bullseye
RUN apt-get update && apt-get install -y --no-install-recommends git shared-mime-info
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl jq iputils-ping telnet openssl
WORKDIR /app
COPY --from=builder-gems /usr/local/bundle /usr/local/bundle
COPY ./api /app
RUN rm /app/Gemfile.lock
COPY --from=builder-gems /build/shared/Gemfile.lock /app/Gemfile.lock
RUN rm -rf /app/.env && touch /app/.env
RUN rm -rf /app/data
RUN mkdir /app/data
RUN chown 1000:1000 /app/data

USER 1000
RUN bundle config set --local without 'development:test'
WORKDIR /app
CMD ["bash", "./init.sh"]
