FROM ruby:3.3.0-bookworm

RUN useradd -d /app -m -s /bin/bash -u 1001 app
USER app

RUN set -eux ; \
    gem update --system ; \
    gem install bundler

WORKDIR /app

ADD --chown=app Gemfile /app/
ADD --chown=app Gemfile.lock /app/

RUN set -eux ; \
    bundle config set deployment true ; \
    bundle install

ADD --chown=app app /app/
