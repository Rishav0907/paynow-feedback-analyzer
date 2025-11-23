# Multi-stage build for optimized production image

# Stage 1: Build the application
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci

# Copy all source files
COPY . .

# Create .env.local file with API key from build arg
ARG GEMINI_API_KEY
RUN echo "GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Build the application
RUN npm run build

# Stage 2: Production server with Nginx
FROM nginx:alpine

# Install nodejs for potential runtime needs
RUN apk add --no-cache nodejs

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy package.json for metadata
COPY --from=builder /app/package.json /usr/share/nginx/html/

# Expose port 8080 (Google Cloud Run uses this port)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
