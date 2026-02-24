#!/bin/bash

# Load environment variables
if [ -f /var/www/.env ]; then
    export $(grep -v '^#' /var/www/.env | xargs)
fi

export PGADMIN_SETUP_EMAIL=${PGADMIN_DEFAULT_EMAIL:-admin@localhost.com}
export PGADMIN_SETUP_PASSWORD=${PGADMIN_DEFAULT_PASSWORD:-admin123}

PGADMIN_PATH=$(find /opt/pgadmin4/lib -type d -name "site-packages" | head -1)
PGADMIN4_DIR="${PGADMIN_PATH}/pgadmin4"
SETUP_PY="${PGADMIN4_DIR}/setup.py"

echo ">>> PGADMIN4_DIR: ${PGADMIN4_DIR}"
echo ">>> Email: ${PGADMIN_SETUP_EMAIL}"

# Buat direktori yang diperlukan
mkdir -p /var/lib/pgadmin/sessions /var/lib/pgadmin/storage /var/log/pgadmin
chown -R www-data:www-data /var/lib/pgadmin /var/log/pgadmin

# Setup database jika belum ada
if [ ! -f /var/lib/pgadmin/pgadmin4.db ]; then
    echo ">>> Initializing pgAdmin4 database..."

    su -s /bin/bash www-data -c "
        export PGADMIN_SETUP_EMAIL='${PGADMIN_SETUP_EMAIL}'
        export PGADMIN_SETUP_PASSWORD='${PGADMIN_SETUP_PASSWORD}'
        cd '${PGADMIN4_DIR}'
        /opt/pgadmin4/bin/python '${SETUP_PY}' setup-db
        echo '>>> setup-db exit: '$?
    "

    chown -R www-data:www-data /var/lib/pgadmin
    echo ">>> Done."
fi

# Verifikasi
if [ -f /var/lib/pgadmin/pgadmin4.db ]; then
    echo ">>> pgadmin4.db exists, size: $(du -sh /var/lib/pgadmin/pgadmin4.db)"
else
    echo ">>> [FATAL] pgadmin4.db tidak terbuat!"
fi

# Start gunicorn
echo ">>> Starting pgAdmin4 gunicorn..."
su -s /bin/bash www-data -c "
    export PGADMIN_SETUP_EMAIL='${PGADMIN_SETUP_EMAIL}'
    export PGADMIN_SETUP_PASSWORD='${PGADMIN_SETUP_PASSWORD}'
    /opt/pgadmin4/bin/gunicorn \
        --bind 0.0.0.0:5050 \
        --workers=1 \
        --threads=25 \
        --chdir '${PGADMIN4_DIR}' \
        --access-logfile /var/log/pgadmin/access.log \
        --error-logfile /var/log/pgadmin/error.log \
        --daemon \
        pgAdmin4:app
"

# Tunggu ready
echo ">>> Waiting for pgAdmin4..."
for i in $(seq 1 30); do
    if curl -sf http://127.0.0.1:5050/ > /dev/null 2>&1; then
        echo ">>> pgAdmin4 is ready!"
        break
    fi
    echo ">>> Waiting... ($i/30)"
    sleep 2
done

service php8.4-fpm start
nginx -g 'daemon off;'