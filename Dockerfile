# --- STAGE 1: BUILD THE REACT APPLICATION ---
# Use the official Node 20 image based on Alpine Linux for a smaller initial size
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package files (package.json and lock file) first to leverage Docker caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# IMPORTANT: Define the build argument for the API key
ARG GEMINI_API_KEY

# Vite applications require environment variables to be prefixed with VITE_.
# This command writes the provided API key into a .env.local file.
# Cloud Build will supply this key during the build process.
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Run the production build command (assuming 'npm run build' is defined in package.json)
# This creates the static assets in the '/app/dist' folder.
RUN npm run build

# --- STAGE 2: SERVE THE STATIC FILES USING NGINX ---
# Use the lightweight Nginx Alpine image to serve the built files securely
FROM nginx:alpine AS final

# Cloud Run requires the container to listen on the port specified by the PORT environment variable.
# We configure Nginx to listen on 8080 (which is the default expectation for Nginx in this scenario,
# and we will configure Cloud Run to use 8080).
ENV PORT 8080

# Copy the custom Nginx configuration file
# This file is essential for listening on the correct port and handling React's routing (SPA).
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the static, optimized build files from the 'build' stage into Nginx's public directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the port (Cloud Run will ignore this but it's good practice)
EXPOSE 8080

# Run Nginx in the foreground so the container stays alive
CMD ["nginx", "-g", "daemon off;"]
