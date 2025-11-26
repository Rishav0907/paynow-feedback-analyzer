# --------------------------------------------------------------------------------
# Stage 1: Build the React Application
# Uses a powerful Node image to install dependencies and run the production build.
# --------------------------------------------------------------------------------
FROM node:20-alpine as builder

# Set the working directory inside the container
WORKDIR /app

# Define the build argument for the API key. Cloud Build will inject this.
ARG GEMINI_API_KEY

# Copy package files first to leverage Docker layer caching
COPY package*.json ./
RUN npm install --silent

# Copy the rest of the source code
COPY . .

# 🚨 CRITICAL STEP: Write the secret key into a local environment file.
# We use the VITE_ prefix, which is common for modern React projects (Vite, etc.).
# If your project uses REACT_APP_, change VITE_GEMINI_API_KEY to REACT_APP_GEMINI_API_KEY
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Execute the production build command (this creates the static files in the 'build' folder)
RUN npm run build

# --------------------------------------------------------------------------------
# Stage 2: Serve the application with Nginx
# Uses a minimal Nginx image to serve the static build from the previous stage.
# --------------------------------------------------------------------------------
FROM nginx:alpine

# The port Cloud Run expects to find your application on
EXPOSE 8080

# Copy the custom nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built files from the 'builder' stage into the Nginx public folder
# Check your build output. If it's 'dist' instead of 'build', change the path below.
COPY --from=builder /app/build /usr/share/nginx/html

# Run Nginx in the foreground. This command ensures the container keeps running.
CMD ["nginx", "-g", "daemon off;"]
