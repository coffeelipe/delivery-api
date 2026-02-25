#!/bin/sh

# Replace API_URL placeholder with actual value from environment
if [ -n "$API_URL" ]; then
    echo "Configuring API URL to: $API_URL"
    find /usr/share/nginx/html -type f -name "*.js" -exec sed -i "s|__API_URL__|$API_URL|g" {} +
fi

# Execute the CMD
exec "$@"
