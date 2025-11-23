# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies using 'npm install' since package-lock.json doesn't exist.
# This will install ALL dependencies (dev and production).
RUN npm install

# Copy source code
COPY . .

# Build arguments for environment variables
# Note: GEMINI_API_KEY should be provided as build arg or env var
ARG GEMINI_API_KEY
ENV GEMINI_API_KEY=${GEMINI_API_KEY}

# Build the application
# The build process will embed the API key via Vite's define config
RUN npm run build

# Production stage
FROM nginx:alpine

# Install envsubst for environment variable substitution
RUN apk add --no-cache gettext

# Copy custom nginx config template
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy and set permissions for entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose port (Cloud Run sets PORT env var, defaults to 8080)
EXPOSE 8080

# Use custom entrypoint to handle PORT environment variable
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
