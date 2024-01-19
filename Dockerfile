# Use an official Apache image as base
FROM httpd:2.4

# Copy your static website files to the web server directory
COPY ./app /usr/local/apache2/htdocs/

# Expose port for web traffic
EXPOSE 9998