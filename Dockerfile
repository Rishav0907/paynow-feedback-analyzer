# --- STAGE 1: BUILD THE REACT APPLICATION ---
FROM node:20-alpine as build

WORKDIR /app

# 1. Capture the GEMINI_API_KEY as a build argument
ARG GEMINI_API_KEY

# 2. Write the API key into a .env.local file (for the React build to use if needed)
RUN echo "VITE_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the React application.
RUN npm run build


# --- STAGE 2: SERVE THE APPLICATION WITH NGINX AND RUNTIME INJECTION ---
FROM nginx:alpine

# Install gettext for the 'envsubst' utility
RUN apk add --no-cache gettext

EXPOSE 8080

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy the built React files
COPY --from=build /app/dist /usr/share/nginx/html

# *** CRUCIAL STEP: Create the entrypoint script directly in the Dockerfile ***
# This script performs the substitution at container startup.
# We are assuming the secret is mapped to the 'API_KEY' environment variable in Cloud Run.
RUN echo '#!/bin/sh' > /docker-entrypoint.sh \
    && echo 'set -e' >> /docker-entrypoint.sh \
    && echo '' >> /docker-entrypoint.sh \
    && echo '# Substitute the $$API_KEY$$ placeholder with the $API_KEY environment variable value' >> /docker-entrypoint.sh \
    && echo 'envsubst '\''$$API_KEY$$'\'' < /usr/share/nginx/html/index.html > /tmp/index.html' >> /docker-entrypoint.sh \
    && echo 'mv /tmp/index.html /usr/share/nginx/html/index.html' >> /docker-entrypoint.sh \
    && echo '' >> /docker-entrypoint.sh \
    && echo '# Execute the main Nginx command' >> /docker-entrypoint.sh \
    && echo 'exec nginx -g "daemon off;"' >> /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

# Change the command to run the custom entrypoint script
CMD ["/docker-entrypoint.sh"]
