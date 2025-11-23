# Stage 1: Build the React Application
# Uses a lightweight Node.js image to install dependencies and run the build command.
FROM node:20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy dependency files first to leverage Docker layer caching
COPY package.json package-lock.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the application (output goes to the 'build' directory)
RUN npm run build

# -------------------------------------------------------------

# Stage 2: Serve the Static Output with Nginx
# Uses a minimal Nginx image to serve the static files from the build stage.
FROM nginx:stable-alpine AS runner

# Configure Nginx for Cloud Run and SPA (Single Page Application) routing
# Nginx is typically configured to listen on port 80 or 8080.
# Cloud Run injects the required port via the $PORT environment variable,
# but for static Nginx serving, listening on the default port 80 is often simplest.

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom configuration for SPA routing (see step B below)
COPY nginx-spa.conf /etc/nginx/conf.d/default.conf

# Copy the built application files from the 'builder' stage into Nginx's web root
COPY --from=builder /app/build /usr/share/nginx/html

# Expose the port Nginx is listening on
EXPOSE 80

# Nginx starts automatically
