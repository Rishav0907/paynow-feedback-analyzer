# --- STAGE 1: BUILD THE REACT APPLICATION ---
# Use the official Node 20 Alpine image for a lightweight build environment
FROM node:20-alpine as build

# Set the working directory inside the container
WORKDIR /app

# 1. Capture the GEMINI_API_KEY passed during the build process
# We use an ARG here so Google Cloud Build can pass it in.
ARG GEMINI_API_KEY

# 2. Write the API key into a .env.local file
# React apps (especially those created with Vite) can read these variables during the build.
RUN echo "VITE_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local
# If your React app uses REACT_APP_ prefix instead of VITE_ prefix, use:
# RUN echo "REACT_APP_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Copy package files to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the React application. 
# This command runs your build script and creates the production files (usually in a 'dist' folder).
RUN npm run build


# --- STAGE 2: SERVE THE APPLICATION WITH NGINX ---
# Use a highly optimized, lightweight Nginx image
FROM nginx:alpine

# Expose the port Cloud Run expects us to listen on
EXPOSE 8080

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom Nginx configuration and the built React files
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

# Command to run Nginx in the foreground (required by Cloud Run)
CMD ["nginx", "-g", "daemon off;"]
