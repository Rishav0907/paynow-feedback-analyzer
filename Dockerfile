# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
# Note: GEMINI_API_KEY should be provided at runtime via environment variables
# For build-time, you may need to set it if your build process requires it
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port (Cloud Run will set PORT env var, but nginx defaults to 80)
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

