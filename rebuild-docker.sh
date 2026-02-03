
#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "Stopping existing containers..."
docker compose down

echo "Rebuilding Docker containers..."
echo "$PASSWORD_ROOT" | sudo -S chown -R $USER:$USER www/phpmyadmin/tmp
docker compose build
echo "$PASSWORD_ROOT" | sudo -S chown -R www-data:www-data www/phpmyadmin/tmp

echo "Starting Docker containers..."
docker compose up -d

echo "List of running containers:"
docker compose ps

echo "If there are any issues, please check the container logs for more details."
echo "To view logs, use: docker compose logs -f"
echo "Docker containers rebuilt and started successfully."
echo "You can access the server at http://localhost and phpMyAdmin at http://localhost/phpmyadmin"