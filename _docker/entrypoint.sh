#!/bin/sh
set -e # Скрипт падает при любой ошибке

MAX_RETRIES=10
RETRY_COUNT=0

echo "host: ${BOOKINGS_MARIA_DB_HOST}"
echo "port: ${BOOKINGS_MARIA_DB_PORT_INNER}"

echo "⏳ Waiting for MariaDB at ${BOOKINGS_MARIA_DB_HOST}:${BOOKINGS_MARIA_DB_PORT_INNER}..."
until nc -z "$BOOKINGS_MARIA_DB_HOST" "$BOOKINGS_MARIA_DB_PORT_INNER"; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "✅ Attempt $RETRY_COUNT"
  if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    echo "❌ Failed to connect to MariaDB after ${MAX_RETRIES} attempts. Exiting."
    exit 1
  fi
  sleep 1
done
echo "✅ MariaDB is available!"

# Проверка соединения к MariaDB
echo "🔐 Verifying connection to MariaDB..."
mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$BOOKINGS_MARIA_DB_USER" -p"$BOOKINGS_MARIA_DB_PASSWORD" -e "SELECT 1;" > /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Unable to connect to MariaDB."
  exit 1
fi

# Проверка и создание базы данных
echo "🔍 Checking if database '${BOOKINGS_MARIA_DB_DB}' exists..."
DB_EXISTS=$(mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$BOOKINGS_MARIA_DB_USER" -p"$BOOKINGS_MARIA_DB_PASSWORD" -sse "SHOW DATABASES LIKE '${BOOKINGS_MARIADB_DB}';")

if [ "$DB_EXISTS" != "$BOOKINGS_MARIADB_DB" ]; then
  echo "🛠 Creating database '${BOOKINGS_MARIADB_DB}'..."
  mysql -h "$BOOKINGS_MARIADB_HOST" -P "$BOOKINGS_MARIADB_PORT" -u "$BOOKINGS_MARIADB_USER" -p"$BOOKINGS_MARIADB_PASSWORD" -e "CREATE DATABASE ${BOOKINGS_MARIADB_DB};"
  echo "✅ Database created."
else
  echo "📦 Database '${BOOKINGS_MARIADB_DB}' already exists."
fi

# Путь к корню микросервиса
#BOOKINGS_SERVICE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
#echo "📁 BOOKINGS_SERVICE_ROOT=${BOOKINGS_SERVICE_ROOT}"

# Если будут миграции — можно раскомментировать:
# echo "📄 Running DB migrations..."
# sh "${BOOKINGS_SERVICE_ROOT}/db/migrate.sh"

# Запуск приложения (переданный через "--" аргумент: java -jar ...)
echo "🚀 Starting bookings-service..."
exec "$@"
