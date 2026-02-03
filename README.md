# LEMP Server with Docker

This project is a LEMP Stack (Linux, Nginx, MariaDB, PHP) implementation using Docker and Docker Compose. The server comes pre-configured with self-signed SSL, PHP 8.4, Node.js 24, and phpMyAdmin for database management.

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

## ✨ Features

- **LEMP Stack**: Linux (Ubuntu 24.04), Nginx, MariaDB 11, PHP 8.4
- **Docker & Docker Compose**: Containerized for easy deployment
- **SSL/HTTPS**: Pre-configured self-signed SSL certificate
- **phpMyAdmin**: Web interface for database management
- **Node.js & npm**: Node.js 24 via NVM for frontend development
- **Composer**: PHP dependency manager
- **Auto HTTP to HTTPS Redirect**: Automatic security
- **Theme Toggle**: Light/Dark/System mode on the main page
- **Hot Reload**: Code changes instantly updated through volume mounting

## 🛠 Tech Stack

| Technology     | Version | Description                   |
| -------------- | ------- | ----------------------------- |
| Ubuntu         | 24.04   | Base OS                       |
| Nginx          | Latest  | Web Server                    |
| PHP            | 8.4     | Server-side Scripting         |
| MariaDB        | 11      | Database Server               |
| Node.js        | 24      | JavaScript Runtime            |
| Composer       | Latest  | PHP Package Manager           |
| phpMyAdmin     | 5.2.3   | Database Management Tool      |
| Docker         | Latest  | Containerization Platform     |
| Docker Compose | Latest  | Multi-container Orchestration |

## 📦 Prerequisites

Before starting, ensure your system has the following installed:

- Docker (version 20.10 or newer)
- Docker Compose (version 2.0 or newer)
- Git (for cloning repository)
- Linux/macOS/Windows with WSL2

### Docker Installation (Ubuntu/Debian)

```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 🚀 Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd "LEMP Server"
```

### 2. Create Environment File

Copy the `.env.example` file to `.env` and adjust the configuration:

```bash
cp .env.example .env
```

Edit the `.env` file with your favorite editor:

```bash
nano .env
```

Example `.env` configuration:

```env
PASSWORD_ROOT=your_sudo_password
DB_PASSWORD_ROOT=your_mysql_root_password
DB_HOST=db
DB_DATABASE=my_database
DB_USER=my_user
DB_PASSWORD=your_db_password
BLOWFISH_SECRET=your_32_character_random_string
DB_COMPRESS=false
ALLOW_NO_PASSWORD=true
```

**Environment Variables Explanation:**

**System Variables:**

- `PASSWORD_ROOT`: Sudo password for running rebuild script

**Database Variables:**

- `DB_PASSWORD_ROOT`: Password for MariaDB root user
- `DB_HOST`: Database hostname (use `db` for Docker, `localhost` for local)
- `DB_DATABASE`: Database name to be created automatically
- `DB_USER`: Database username for application
- `DB_PASSWORD`: Password for database user

**phpMyAdmin Variables:**

- `BLOWFISH_SECRET`: 32-character secret key for cookie encryption (required for phpMyAdmin)
- `DB_COMPRESS`: Enable/disable database connection compression (true/false)
- `ALLOW_NO_PASSWORD`: Allow login without password (true/false, use `false` in production)

### 3. Run Containers

**Method 1: Using Script (Recommended)**

```bash
chmod +x rebuild-docker.sh
./rebuild-docker.sh
```

This script will:

- Stop running containers
- Rebuild Docker image
- Set correct permissions for phpMyAdmin
- Start all containers
- Display container status

**Method 2: Manual with Docker Compose**

```bash
# Build image
docker compose build

# Start containers
docker compose up -d

# View status
docker compose ps

# View logs
docker compose logs -f
```

## ⚙️ Configuration

### Nginx Configuration

The Nginx configuration file is located at [`conf/default.conf`](conf/default.conf). The default configuration includes:

- HTTP to HTTPS redirect
- PHP-FPM integration
- SSL configuration
- URL rewriting

### PHP Configuration

Installed PHP extensions:

- `php8.4-fpm`: FastCGI Process Manager
- `php8.4-mysql`: MySQL/MariaDB support
- `php8.4-cli`: Command Line Interface
- `php8.4-curl`: cURL support
- `php8.4-mbstring`: Multi-byte string support
- `php8.4-xml`: XML support
- `php8.4-zip`: ZIP support

### Environment Loader Utility

The project includes a `loadEnv.php` utility for loading environment variables from `.env` file:

```php
<?php
require_once __DIR__ . '/loadEnv.php';
loadEnv('/var/www/.env');

// Access environment variables
$dbHost = getenv('DB_HOST');
$dbName = $_ENV['DB_DATABASE'];
$dbUser = $_SERVER['DB_USER'];
?>
```

This utility is used by phpMyAdmin and can be used in your PHP applications to access configuration variables.

### SSL Certificate

A self-signed SSL certificate will be automatically created during image build. The certificate is valid for 365 days and uses the following configuration:

```
Country: ID
State: Jakarta
Location: Jakarta
Organization: LocalDev
Common Name: localhost
```

## 📱 Usage

### Accessing the Application

Once the containers are running, you can access:

- **Web Server**: https://localhost
  - Automatically redirects from http://localhost
- **phpMyAdmin**: https://localhost/phpmyadmin
  - Username: `root` or user from `.env`
  - Password: according to configuration in `.env`
- **PHP Info**: https://localhost/info.php

### Useful Docker Compose Commands

```bash
# View container status
docker compose ps

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f app
docker compose logs -f db

# Stop containers
docker compose stop

# Start containers
docker compose start

# Restart containers
docker compose restart

# Stop and remove containers
docker compose down

# Stop, remove containers and volumes
docker compose down -v

# Rebuild image
docker compose build --no-cache

# Enter container
docker exec -it lemp_node bash
docker exec -it mariadb bash
```

### Managing Database

**Via phpMyAdmin:**

1. Access https://localhost/phpmyadmin
2. Login with credentials from `.env`
3. Create databases, tables, and manage data through the interface

**Via Command Line:**

```bash
# Enter MariaDB container
docker exec -it mariadb bash

# Login to MariaDB (from inside container)
mariadb -u root -p
# or
mysql -u root -p

# Or directly from host
docker exec -it mariadb mariadb -u root -p
docker exec -it mariadb mysql -u root -p
```

### Running PHP Commands

```bash
# Enter app container
docker exec -it lemp_node bash

# Run PHP script
php /var/www/html/your-script.php

# Install Composer dependencies
cd /var/www/html
composer install

# Update Composer dependencies
composer update
```

### Running Node.js/npm Commands

```bash
# Enter app container
docker exec -it lemp_node bash

# Verify Node.js and npm
node --version
npm --version

# Install npm packages
npm install

# Run npm scripts
npm run dev
npm run build
```

## 📁 Project Structure

```
LEMP Server/
├── docker-compose.yml          # Orchestration configuration
├── Dockerfile                  # Image build instructions
├── README.md                   # Project documentation
├── rebuild-docker.sh           # Script for rebuild & restart
├── .env                        # Environment variables (not committed)
├── .env.example                # Template environment variables
├── conf/
│   └── default.conf           # Nginx configuration
└── www/                       # Web root directory (mounted as volume)
    ├── index.php              # Homepage
    ├── info.php               # PHP info page
    ├── loadEnv.php            # Environment loader utility
    ├── css/
    │   └── style.css          # Styling
    ├── icon/
    │   └── nginx.png          # Favicon
    ├── js/
    │   └── theme-toggle.js    # Theme switcher
    └── phpmyadmin/            # phpMyAdmin installation
        ├── config.inc.php     # phpMyAdmin config
        └── ...                # phpMyAdmin files
```

### Important Files

- **docker-compose.yml**: Defines services (app & db), networks, and volumes
- **Dockerfile**: Instructions for building Ubuntu image with LEMP stack
- **conf/default.conf**: Nginx configuration for routing and SSL
- **www/**: Directory mounted to container, all web files here
- **www/loadEnv.php**: Utility function to load environment variables from `.env`
- **www/phpmyadmin/config.inc.php**: phpMyAdmin configuration with environment variable support
- **rebuild-docker.sh**: Automated script for rebuilding and restarting containers
- **.env**: Environment configuration (created from `.env.example`, not committed to git)

## 🔧 Troubleshooting

### Port Already in Use

If ports 80, 443, or 3306 are already in use:

```bash
# Check which service is using the port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :3306

# Stop conflicting service (example: Nginx)
sudo systemctl stop nginx
sudo systemctl stop mysql

# Or change port in docker-compose.yml
ports:
  - "8080:80"
  - "8443:443"
  - "3307:3306"
```

### Permission Denied on phpMyAdmin

If phpMyAdmin shows permission error:

```bash
# Set correct permissions
sudo chown -R www-data:www-data www/phpmyadmin/tmp
sudo chmod -R 755 www/phpmyadmin/tmp
```

### phpMyAdmin Configuration Error

If you see "Failed to load phpMyAdmin configuration" or syntax errors:

1. **Check BLOWFISH_SECRET**: Ensure it's set in `.env` (32 characters recommended)

   ```bash
   # Generate a random secret
   openssl rand -hex 16
   ```

2. **Verify loadEnv.php path**: The config file should reference `../loadEnv.php` correctly

3. **Check declare(strict_types=1)**: Must be the first statement after `<?php`

### Container Cannot Start

```bash
# View logs for detailed error
docker compose logs -f

# Rebuild from scratch without cache
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Database Connection Failed

1. Ensure `db` service is running:

   ```bash
   docker compose ps
   ```

2. Check environment variables in `.env` are correct

3. Test database connection:

   ```bash
   docker exec -it mariadb mysql -u root -p
   ```

4. Ensure `DB_HOST` in `.env` is `db` (not `localhost`)

### SSL Certificate Warning

Browsers will show a warning because it uses a self-signed certificate. This is normal for development environments.

**Chrome/Edge**: Click "Advanced" → "Proceed to localhost (unsafe)"
**Firefox**: Click "Advanced" → "Accept the Risk and Continue"

For production, use Let's Encrypt or a certificate from a trusted CA.

### Rebuild Clean Installation

If you want to start fresh:

```bash
# Stop and remove everything
docker compose down -v

# Remove images
docker rmi $(docker images -q)

# Rebuild and start
./rebuild-docker.sh
```

## 🔒 Security

**For Development:**

- This project uses self-signed SSL certificate
- Credentials stored in `.env` (ensure `.env` is in `.gitignore`)
- Default `ALLOW_NO_PASSWORD=true` for easy local development

**For Production:**

- Replace self-signed certificate with certificate from trusted CA (Let's Encrypt)
- Use strong and unique passwords
- Generate a secure `BLOWFISH_SECRET` (32+ characters): `openssl rand -hex 16`
- Set `ALLOW_NO_PASSWORD=false` in phpMyAdmin configuration
- Don't commit `.env` file to repository
- Enable firewall and restrict access to database port
- Keep all dependencies updated
- Disable `info.php` or restrict access
- Use environment-specific `.env` files for different stages

## 🤝 Contributing

Contributions welcome! Please create an issue or pull request for:

- Bug fixes
- Feature requests
- Documentation improvements
- Performance optimizations

## 📄 License

This project is free to use for development and learning purposes.

## 👤 Author

Built with ❤️ to simplify LEMP development environment setup

## 📚 References

- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Documentation](https://www.php.net/docs.php)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [phpMyAdmin Documentation](https://www.phpmyadmin.net/docs/)

---

**Happy Coding! 🚀**
