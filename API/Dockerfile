FROM ruby:4.0.1-slim-trixie

WORKDIR /app

# Install dependencies including curl for healthchecks
RUN <<EOF
apt-get update
apt-get install -y build-essential git libyaml-dev curl
rm -rf /var/lib/apt/lists/*
EOF

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Make entrypoint executable
RUN chmod +x docker-entrypoint.sh

# Create directories
RUN mkdir -p storage tmp/pids

EXPOSE 3000

# Set environment to production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

# Use entrypoint script
ENTRYPOINT ["./docker-entrypoint.sh"]

# Start server
CMD ["bundle", "exec", "rails", "server", "--binding", "0.0.0.0"]
