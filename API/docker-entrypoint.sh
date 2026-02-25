#!/bin/bash
set -e

echo "Starting Rails application setup..."

# Create database if it doesn't exist and run migrations
echo "Setting up database..."
bundle exec rails db:prepare

# Seed the database if it's empty
echo "Seeding database..."
bundle exec rails db:seed

echo "Starting Rails server..."
exec "$@"
