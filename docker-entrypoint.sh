#!/bin/sh
set -e

# Set default PORT if not provided (Cloud Run will set this automatically)
export PORT=${PORT:-8080}

# Substitute PORT variable in nginx config template
envsubst '$PORT' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Execute the original command
exec "$@"
