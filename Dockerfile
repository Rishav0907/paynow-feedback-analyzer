# --- STAGE 1: Builder Stage ---
# Use the node:20-alpine image for a fast and light build environment.
FROM node:20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Accept the API key as a build argument
ARG GEMINI_API_KEY
# If your Vite app uses a prefix (e.g., REACT_APP_ or VITE_), update the key name here.
ENV VITE_GEMINI_API_KEY=$GEMINI_API_KEY

# Copy package files first to leverage Docker caching (if dependencies haven't changed)
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Write the API key argument to a .env.local file.
# This makes the key available during the 'npm run build' process for the bundler (Vite/Webpack).
RUN echo "VITE_GEMINI_API_KEY=${VITE_GEMINI_API_KEY}" > .env.local

# Execute the build command (which creates the 'dist' folder for Vite apps)
RUN npm run build

# --- STAGE 2: Production/Runtime Stage ---
# Use a minimal Nginx image to serve the static content.
FROM nginx:alpine

# Copy the custom Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built React assets (from the 'builder' stage) to the Nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Cloud Run requires the container to listen on the port specified by the $PORT environment variable,
# which defaults to 8080 if not set. We configure Nginx to listen on 8080 internally.
EXPOSE 8080

# Run Nginx in the foreground. Cloud Run requires the main container process to stay running.
CMD ["nginx", "-g", "daemon off;"]
