#!/bin/bash
set -e

echo "Starting Rails application setup..."

# Generate SECRET_KEY_BASE if not provided
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "SECRET_KEY_BASE not set. Generating a random one..."
  export SECRET_KEY_BASE=$(openssl rand -hex 64)
fi

# Create database if it doesn't exist and run migrations
echo "Setting up database..."
bundle exec rails db:prepare

# Seed the database if it's empty
echo "Seeding database..."
bundle exec rails db:seed

echo "Starting Rails server..."
exec "$@"
