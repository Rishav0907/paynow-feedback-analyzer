# --- STAGE 1: BUILDER ---
# Use the Node 20 Alpine image to build the React application
FROM node:20-alpine AS builder

WORKDIR /app

# 1. Define the build argument for the API key
# This variable is passed by Google Cloud Build during the process
ARG GEMINI_API_KEY

# Copy package files first to leverage Docker caching (if dependencies don't change, this step is skipped)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your application code
COPY . .

# 2. Write the API Key into .env.local before building
# This file is read by React build tools, embedding the key into the static files.
# We prefix it with REACT_APP_ so React knows to include it.
RUN echo "REACT_APP_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Build the application
RUN npm run build

# --- STAGE 2: PRODUCTION SERVER ---
# Use the lightweight Nginx Alpine image to serve the final static files
FROM nginx:alpine

# 3. Expose port 8080 (Cloud Run's default port)
EXPOSE 8080

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# 4. Create a custom Nginx configuration file
# This config tells Nginx to:
# - Listen on port 8080.
# - Use 'try_files' to handle Single Page Application (SPA) routing,
#   meaning all requests that aren't for a file go to index.html.
RUN echo 'server {\n\
    listen 8080;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html index.htm;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}' > /etc/nginx/conf.d/default.conf

# Copy the built React app from the builder stage into the Nginx serving directory
COPY --from=builder /app/build /usr/share/nginx/html

# 5. Run Nginx in the foreground (required by container orchestrators like Cloud Run)
CMD ["nginx", "-g", "daemon off;"]
