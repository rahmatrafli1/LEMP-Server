# LEMP Server with Docker

This project is a LEMP Stack (Linux, Nginx, MariaDB, PHP) implementation using Docker and Docker Compose. The server comes pre-configured with self-signed SSL, PHP 8.4, Node.js 24, phpMyAdmin for MySQL/MariaDB management, and PgAdmin4 for PostgreSQL management.

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
- **PostgreSQL 17**: Modern open-source relational database
- **Docker & Docker Compose**: Containerized for easy deployment
- **SSL/HTTPS**: Pre-configured self-signed SSL certificate
- **phpMyAdmin**: Web interface for MySQL/MariaDB management
- **PgAdmin4**: Web interface for PostgreSQL management
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
| MariaDB        | 11      | MySQL Database Server         |
| PostgreSQL     | 17      | Advanced SQL Database         |
| Node.js        | 24      | JavaScript Runtime            |
| Composer       | Latest  | PHP Package Manager           |
| phpMyAdmin     | 5.2.3   | MySQL/MariaDB Management      |
| PgAdmin4       | Latest  | PostgreSQL Management         |
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
# System Variables
PASSWORD_ROOT=your_sudo_password

# MariaDB/MySQL Variables
DB_PASSWORD_ROOT=your_mysql_root_password
DB_HOST=db
DB_DATABASE=my_database
DB_USER=my_user
DB_PASSWORD=your_db_password

# phpMyAdmin Variables
BLOWFISH_SECRET=your_32_character_random_string
DB_COMPRESS=false
ALLOW_NO_PASSWORD=true

# PostgreSQL Variables
POSTGRES_HOST=postgres
POSTGRES_DB=appdb_pg
POSTGRES_USER=pguser
POSTGRES_PASSWORD=your_postgres_password

# PgAdmin4 Variables
PGADMIN_DEFAULT_EMAIL=admin@localhost.com
PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password
```

**Environment Variables Explanation:**

**System Variables:**

- `PASSWORD_ROOT`: Sudo password for running rebuild script

**MariaDB/MySQL Variables:**

- `DB_PASSWORD_ROOT`: Password for MariaDB root user
- `DB_HOST`: Database hostname (use `db` for Docker container)
- `DB_DATABASE`: Database name to be created automatically
- `DB_USER`: Database username for application
- `DB_PASSWORD`: Password for database user

**phpMyAdmin Variables:**

- `BLOWFISH_SECRET`: 32-character secret key for cookie encryption (required for phpMyAdmin)
- `DB_COMPRESS`: Enable/disable database connection compression (true/false)
- `ALLOW_NO_PASSWORD`: Allow login without password (true/false, use `false` in production)

**PostgreSQL Variables:**

- `POSTGRES_HOST`: PostgreSQL hostname (use `postgres` for Docker container)
- `POSTGRES_DB`: PostgreSQL database name
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL user password

**PgAdmin4 Variables:**

- `PGADMIN_DEFAULT_EMAIL`: Default email for PgAdmin4 login
- `PGADMIN_DEFAULT_PASSWORD`: Default password for PgAdmin4 login

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
- Start all containers (app, MariaDB, PostgreSQL)
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
- PgAdmin4 reverse proxy at `/pgadmin4/`

### PHP Configuration

Installed PHP extensions:

- `php8.4-fpm`: FastCGI Process Manager
- `php8.4-mysql`: MySQL/MariaDB support
- `php8.4-pgsql`: PostgreSQL support
- `php8.4-cli`: Command Line Interface
- `php8.4-curl`: cURL support
- `php8.4-mbstring`: Multi-byte string support
- `php8.4-xml`: XML support
- `php8.4-zip`: ZIP support
- `php8.4-gd`: GD image library
- `php8.4-intl`: Internationalization extension

### PostgreSQL Configuration

PostgreSQL is configured with:

- Version: 17 (latest stable)
- Port: 5432 (exposed to host)
- Data persistence via Docker volume
- Automatic database creation on first run
- Network isolation via Docker network

### PgAdmin4 Configuration

PgAdmin4 is installed inside the main app container with:

- Python virtual environment at `/opt/pgadmin4`
- Gunicorn as WSGI server
- Unix socket communication with Nginx
- Persistent storage for configurations
- Accessible via HTTPS at `/pgadmin4/`

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

// PostgreSQL connection
$pgHost = getenv('POSTGRES_HOST');
$pgDb = getenv('POSTGRES_DB');
$pgUser = getenv('POSTGRES_USER');
?>
```

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
- **PgAdmin4**: https://localhost/pgadmin4/
  - Email: from `PGADMIN_DEFAULT_EMAIL` in `.env`
  - Password: from `PGADMIN_DEFAULT_PASSWORD` in `.env`
- **PHP Info**: https://localhost/info.php
- **PostgreSQL Test**: https://localhost/test_postgres.php

### Configuring PostgreSQL Server in PgAdmin4

1. Access https://localhost/pgadmin4/
2. Login with credentials from `.env` file
3. Click "Add New Server"
4. In "General" tab:
   - Name: `Local PostgreSQL` (or any name you prefer)
5. In "Connection" tab:
   - Host: `postgres` (Docker service name)
   - Port: `5432`
   - Maintenance database: Value from `POSTGRES_DB` in `.env` (e.g., `appdb_pg`)
   - Username: Value from `POSTGRES_USER` in `.env` (e.g., `pguser`)
   - Password: Value from `POSTGRES_PASSWORD` in `.env`
   - Save password: ✓ (optional)
6. Click "Save"

### Useful Docker Compose Commands

```bash
# View container status
docker compose ps

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f app
docker compose logs -f db
docker compose logs -f postgres

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

# Enter containers
docker exec -it lemp_node bash
docker exec -it mariadb bash
docker exec -it postgres bash
```

### Managing MariaDB Database

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

### Managing PostgreSQL Database

**Via PgAdmin4:**

1. Access https://localhost/pgadmin4/
2. Login with PgAdmin4 credentials
3. Connect to PostgreSQL server (see "Configuring PostgreSQL Server" above)
4. Create databases, schemas, tables, and manage data

**Via Command Line:**

```bash
# Enter PostgreSQL container
docker exec -it postgres bash

# Login to PostgreSQL (from inside container)
psql -U pguser -d appdb_pg

# Or directly from host
docker exec -it postgres psql -U pguser -d appdb_pg

# Common PostgreSQL commands:
\l          # List databases
\c dbname   # Connect to database
\dt         # List tables
\d table    # Describe table
\q          # Quit
```

### Connecting to PostgreSQL from PHP

```php
<?php
require_once __DIR__ . '/loadEnv.php';
loadEnv('/var/www/.env');

$host = getenv('POSTGRES_HOST');
$dbname = getenv('POSTGRES_DB');
$user = getenv('POSTGRES_USER');
$password = getenv('POSTGRES_PASSWORD');

try {
    $dsn = "pgsql:host=$host;port=5432;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Connected to PostgreSQL successfully!";

    // Query example
    $stmt = $pdo->query('SELECT version()');
    $version = $stmt->fetch(PDO::FETCH_ASSOC);
    echo $version['version'];

} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
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
├── start.sh                    # Container startup script
├── .env                        # Environment variables (not committed)
├── .env.example                # Template environment variables
├── conf/
│   └── default.conf           # Nginx configuration
└── www/                       # Web root directory (mounted as volume)
    ├── index.php              # Homepage
    ├── info.php               # PHP info page
    ├── test_postgres.php      # PostgreSQL connection test
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

- **docker-compose.yml**: Defines services (app, db, postgres), networks, and volumes
- **Dockerfile**: Instructions for building Ubuntu image with LEMP stack + PostgreSQL + PgAdmin4
- **start.sh**: Startup script that initializes PgAdmin4, PHP-FPM, and Nginx
- **conf/default.conf**: Nginx configuration for routing, SSL, and PgAdmin4 reverse proxy
- **www/**: Directory mounted to container, all web files here
- **www/loadEnv.php**: Utility function to load environment variables from `.env`
- **www/test_postgres.php**: Test script for PostgreSQL connection
- **www/phpmyadmin/config.inc.php**: phpMyAdmin configuration with environment variable support
- **rebuild-docker.sh**: Automated script for rebuilding and restarting containers
- **.env**: Environment configuration (created from `.env.example`, not committed to git)

## 🔧 Troubleshooting

### Port Already in Use

If ports 80, 443, 3306, or 5432 are already in use:

```bash
# Check which service is using the port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :3306
sudo lsof -i :5432

# Stop conflicting service (example: Nginx, MySQL, PostgreSQL)
sudo systemctl stop nginx
sudo systemctl stop mysql
sudo systemctl stop postgresql

# Or change port in docker-compose.yml
ports:
  - "8080:80"
  - "8443:443"
  - "3307:3306"
  - "5433:5432"
```

### Permission Denied on phpMyAdmin

If phpMyAdmin shows permission error:

```bash
# Set correct permissions
sudo chown -R www-data:www-data www/phpmyadmin/tmp
sudo chmod -R 755 www/phpmyadmin/tmp
```

### PgAdmin4 Shows 502 Bad Gateway

If PgAdmin4 returns 502 error:

1. **Check if gunicorn is running:**

   ```bash
   docker exec -it lemp_node ps aux | grep gunicorn
   ```

2. **Check PgAdmin4 logs:**

   ```bash
   docker exec -it lemp_node cat /var/log/pgadmin/error.log
   docker exec -it lemp_node cat /var/log/pgadmin/pgadmin4.log
   ```

3. **Check if socket file exists:**

   ```bash
   docker exec -it lemp_node ls -la /var/run/pgadmin/
   ```

4. **Restart container:**

   ```bash
   docker compose restart app
   ```

### PostgreSQL Connection Refused

If PHP cannot connect to PostgreSQL:

1. **Verify PostgreSQL is running:**

   ```bash
   docker compose ps
   docker compose logs postgres
   ```

2. **Check hostname in connection:**
   - Use `postgres` (service name) not `localhost`
   - Example: `$host = 'postgres';`

3. **Test connection from app container:**

   ```bash
   docker exec -it lemp_node bash
   psql -h postgres -U pguser -d appdb_pg
   ```

### PgAdmin4 Login Failed

If you cannot login to PgAdmin4:

1. **Check credentials in `.env`:**
   - Ensure `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD` are set

2. **Reset PgAdmin4 database:**

   ```bash
   docker exec -it lemp_node rm /var/lib/pgadmin/pgadmin4.db
   docker compose restart app
   ```

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

1. Ensure database service is running:

   ```bash
   docker compose ps
   ```

2. Check environment variables in `.env` are correct

3. Test database connection:

   ```bash
   # MariaDB
   docker exec -it mariadb mysql -u root -p

   # PostgreSQL
   docker exec -it postgres psql -U pguser -d appdb_pg
   ```

4. Ensure hostnames in `.env` use Docker service names:
   - MariaDB: `DB_HOST=db`
   - PostgreSQL: `POSTGRES_HOST=postgres`

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
- PgAdmin4 accessible via HTTPS only

**For Production:**

- Replace self-signed certificate with certificate from trusted CA (Let's Encrypt)
- Use strong and unique passwords for all services
- Generate a secure `BLOWFISH_SECRET` (32+ characters): `openssl rand -hex 16`
- Set `ALLOW_NO_PASSWORD=false` in phpMyAdmin configuration
- Change default PgAdmin4 credentials immediately
- Don't commit `.env` file to repository
- Enable firewall and restrict access to database ports (3306, 5432)
- Keep all dependencies updated
- Disable `info.php` and `test_postgres.php` or restrict access
- Use environment-specific `.env` files for different stages
- Consider using Docker secrets for sensitive data in production
- Implement database connection pooling for better performance
- Regular backup of PostgreSQL and MariaDB data

## 🤝 Contributing

Contributions welcome! Please create an issue or pull request for:

- Bug fixes
- Feature requests
- Documentation improvements
- Performance optimizations
- Security enhancements

## 📄 License

This project is free to use for development and learning purposes.

## 👤 Author

Built with ❤️ to simplify LEMP development environment setup with PostgreSQL support

## 📚 References

- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Documentation](https://www.php.net/docs.php)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [phpMyAdmin Documentation](https://www.phpmyadmin.net/docs/)
- [PgAdmin4 Documentation](https://www.pgadmin.org/docs/)

---

**Happy Coding! 🚀**
