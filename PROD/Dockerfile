# Use nginx:alpine as the base image
FROM nginx:alpine

# Remove the default HTML content
RUN rm -rf /usr/share/nginx/html/*

# Copy your custom HTML files into Nginx's default directory
COPY ./ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]
