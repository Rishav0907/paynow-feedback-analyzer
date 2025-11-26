# ----------------------------------------------------------------------
# STAGE 1: BUILD THE REACT APPLICATION
# ----------------------------------------------------------------------
FROM node:20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker caching.
# This step only runs again if dependencies change.
COPY package.json package-lock.json ./

# Define a build argument for the API key.
# This variable is needed at BUILD time to be included in the production JS bundle.
ARG GEMINI_API_KEY

# Install dependencies
RUN npm install

# Copy the rest of your application source code
COPY . .

# IMPORTANT STEP: Write the API key to a .env.local file.
# This file is typically picked up by tools like Create React App or Vite during 'npm run build'.
# We use the build argument (ARG) here.
# Note: For security, never rely on this as the only protection. Environment variables 
# written to a build environment are typically visible in the resulting web bundle.
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Run the build command to generate the static files (usually in a 'build' or 'dist' folder)
RUN npm run build

# ----------------------------------------------------------------------
# STAGE 2: SERVE THE APPLICATION WITH NGINX
# ----------------------------------------------------------------------
# Use a lightweight Nginx image to serve the static files
FROM nginx:alpine

# The default Nginx configuration listens on port 80.
# We must configure it to listen on the port expected by Cloud Run (8080).
# We also ensure it handles single-page app (SPA) routing.
COPY --from=builder /app/build /usr/share/nginx/html

# Custom Nginx configuration:
# 1. Listen on port 8080 (Cloud Run requirement).
# 2. Add 'try_files' to handle client-side routing (important for React apps).
# 3. Increase cache-control for better performance.
RUN echo "server { \
    listen 8080; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files \$uri \$uri/ /index.html; \
        expires max; \
        add_header Cache-Control \"public, max-age=31536000, immutable\"; \
    } \
    error_page 500 502 503 504 /50x.html; \
}" > /etc/nginx/conf.d/default.conf

# Expose the container port (Cloud Run requires the app to listen on the $PORT environment variable, 
# but Nginx is configured statically to 8080 in the custom config above).
EXPOSE 8080

# Run Nginx in the foreground. This is the main command for the container.
CMD ["nginx", "-g", "daemon off;"]
