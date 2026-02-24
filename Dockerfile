# Use official Ubuntu 24.04 as base image
FROM ubuntu:24.04

# Set timezone (optional)
ENV TZ=Asia/Jakarta

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# ---------- Install dependencies ----------
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    gnupg2 \
    ca-certificates \
    lsb-release \
    nginx \
    build-essential \
    git \
    python3 \
    python3-pip \
    python3-venv \
    libpq-dev

# Add PHP 8.4 repo
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
    php8.4-fpm \
    php8.4-mysql \
    php8.4-pgsql \
    php8.4-cli \
    php8.4-curl \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip \
    php8.4-gd \
    php8.4-intl

# ---------- Install Composer ----------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer

# ---------- Generate Self-signed SSL ----------
RUN mkdir -p /etc/ssl/certs && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/certs/selfsigned.key \
    -out /etc/ssl/certs/selfsigned.crt \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=LocalDev/CN=localhost"

# ---------- Install PgAdmin4 ----------
RUN python3 -m venv /opt/pgadmin4 && \
    /opt/pgadmin4/bin/pip install --upgrade pip && \
    /opt/pgadmin4/bin/pip install pgadmin4 gunicorn

# Create pgadmin4 directories
RUN mkdir -p /var/lib/pgadmin /var/log/pgadmin && \
    chown -R www-data:www-data /var/lib/pgadmin /var/log/pgadmin

RUN PGADMIN_PATH=$(find /opt/pgadmin4/lib -type d -name "site-packages" | head -1) && \
    echo 'LOG_FILE = "/var/log/pgadmin/pgadmin4.log"' > ${PGADMIN_PATH}/pgadmin4/config_local.py && \
    echo 'SQLITE_PATH = "/var/lib/pgadmin/pgadmin4.db"' >> ${PGADMIN_PATH}/pgadmin4/config_local.py && \
    echo 'SESSION_DB_PATH = "/var/lib/pgadmin/sessions"' >> ${PGADMIN_PATH}/pgadmin4/config_local.py && \
    echo 'STORAGE_DIR = "/var/lib/pgadmin/storage"' >> ${PGADMIN_PATH}/pgadmin4/config_local.py && \
    echo 'SERVER_MODE = True' >> ${PGADMIN_PATH}/pgadmin4/config_local.py

# ---------- Install NVM + Node ----------
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=24

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    bash -lc "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default"

# Create symlinks for node, npm, and npx
RUN NODE_PATH=$(bash -lc "source $NVM_DIR/nvm.sh && nvm which current") && \
    NODE_DIR=$(dirname $NODE_PATH) && \
    ln -sf $NODE_DIR/node /usr/local/bin/node && \
    ln -sf $NODE_DIR/npm /usr/local/bin/npm && \
    ln -sf $NODE_DIR/npx /usr/local/bin/npx

# Add NVM binaries to PATH
ENV PATH=/usr/local/bin:$PATH

# ---------- Copy nginx config ----------
COPY conf/default.conf /etc/nginx/nginx.conf

# ---------- Copy website files ----------
COPY www /var/www/html

# Copy .env file
COPY .env /var/www/.env

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Working directory and expose ports
WORKDIR /var/www/html
EXPOSE 80 443

# Start services
CMD ["/start.sh"]