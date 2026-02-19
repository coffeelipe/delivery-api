FROM ruby:4.0.1-slim-trixie

WORKDIR /app

RUN <<EOF
apt-get update
apt-get install -y build-essential git libyaml-dev
EOF

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD [ "rails", "server", "--binding", "0.0.0.0" ]
