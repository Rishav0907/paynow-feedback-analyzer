# ------------------------------------
# Stage 1: Build the React Application
# ------------------------------------
# Use the Node 20 Alpine image as the builder base. Alpine is a small, secure Linux distribution.
FROM node:20-alpine AS builder

# Set the working directory for all subsequent commands
WORKDIR /app

# Install necessary tools to handle the build argument and file creation
RUN apk add --no-cache bash

# Declare the build argument for the API Key
ARG GEMINI_API_KEY

# Copy package files first to leverage Docker's build cache
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# IMPORTANT STEP: Write the GEMINI_API_KEY into a .env.local file
# React will automatically pick up REACT_APP_ environment variables from this file during 'npm run build'
RUN echo "REACT_APP_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Build the React application for production
RUN npm run build


# ------------------------------------
# Stage 2: Serve the Static Files with Nginx
# ------------------------------------
# Use the very light Nginx Alpine image for the final production container
FROM nginx:alpine AS final

# Cloud Run requires the container to listen on the port specified by the PORT environment variable.
# We will use 8080 as requested, but Cloud Run often automatically sets the PORT env variable to something else,
# so we need to configure Nginx to read it.

# Copy a custom Nginx configuration file (defined below)
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build artifacts from the 'builder' stage into the Nginx public folder
COPY --from=builder /app/build /usr/share/nginx/html

# Cloud Run expects the app to respond on the port defined by the environment variable PORT, 
# which defaults to 8080 in our Nginx config below.
EXPOSE 8080

# Run Nginx in the foreground so the container doesn't exit immediately
CMD ["nginx", "-g", "daemon off;"]

# --- Internal Nginx Configuration (Create a file named nginx.conf in your root directory) ---
# NOTE: If you prefer to keep your Dockerfile simple, create a separate file named `nginx.conf`
# in your project root with the content below. Then remove the line "COPY ./nginx.conf..."
# and uncomment the "RUN echo..." block below it.
#
# If you make a separate file called `nginx.conf`:
```nginx
server {
    # Cloud Run injects the PORT environment variable. Read it or default to 8080.
    listen ${PORT:-8080};
    location / {
        # Serve the static files from the build directory
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
```
#
# Since we cannot generate two files, let's include the config directly:
#
# If you do NOT want a separate file, you can modify the Dockerfile to write this config
# inline (but using a separate file is cleaner).
# For simplicity and to ensure the file is present for COPY, let's assume you create the file `nginx.conf`
# next to your Dockerfile.
