# --- STAGE 1: BUILDER ---
# Use node:20-alpine for a lightweight, secure build environment.
FROM node:20-alpine AS builder

# Set the working directory for the application source code
WORKDIR /app

# Accept the API key as a build argument
ARG GEMINI_API_KEY

# Copy package files first to leverage Docker's build cache
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Write the API key to a .env.local file so Vite can read it during the build process.
# Vite automatically picks up environment variables prefixed with VITE_ or imported
# from a .env.local file. We assume the key is referenced in the app as VITE_GEMINI_API_KEY.
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Build the application
# Assuming your package.json has a "build" script that generates output in a "dist" folder (default for Vite)
RUN npm run build

# --- STAGE 2: PRODUCTION SERVER ---
# Use a minimal nginx:alpine image to serve the static assets securely and efficiently.
FROM nginx:alpine

# Cloud Run expects the service to listen on the port specified by the PORT environment variable,
# which defaults to 8080 if not set. We configure Nginx to listen on this port.
# Note: Cloud Run *requires* EXPOSE 8080 even if Nginx listens on 80. We stick to 8080 for Nginx.
EXPOSE 8080

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/nginx-spa.conf

# Copy the optimized build artifacts from the builder stage into the Nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Command to run Nginx in the foreground (required by Cloud Run/Docker best practices)
CMD ["nginx", "-g", "daemon off;"]
