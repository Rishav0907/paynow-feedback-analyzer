# Use an official lightweight Nginx image as the base
FROM nginx:alpine

# Copy all your static files into the directory Nginx uses to serve web content
# /usr/share/nginx/html/ is the default location for Nginx static files
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/

# The container will automatically expose and run Nginx on port 80.
