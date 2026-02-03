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
    git

# Add PHP 8.4 repo
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
    php8.4-fpm \
    php8.4-mysql \
    php8.4-cli \
    php8.4-curl \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip

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

# Working directory and expose ports
WORKDIR /var/www/html
EXPOSE 80 443

# Start PHP-FPM and Nginx
CMD service php8.4-fpm start && nginx -g 'daemon off;'
