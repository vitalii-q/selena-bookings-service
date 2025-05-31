#!/bin/sh
set -e # Скрипт падает при любой ошибке

MAX_RETRIES=10
RETRY_COUNT=0

#echo "host: ${BOOKINGS_MARIA_DB_HOST}"
#echo "port: ${BOOKINGS_MARIA_DB_PORT_INNER}"

#echo "name: ${BOOKINGS_MARIA_DB_NAME}"
#echo "user: ${BOOKINGS_MARIA_DB_USER}"
#echo "pass: ${BOOKINGS_MARIA_DB_PASSWORD}"

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

# ➕ Проверка и создание пользователя
echo "👤 Checking if user '${BOOKINGS_MARIA_DB_USER}' exists..."
USER_EXISTS=$(mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$ROOT_USER" -p"$ROOT_PASS" -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${BOOKINGS_MARIA_DB_USER}');")
if [ "$USER_EXISTS" = 1 ]; then
  echo "✅ User '${BOOKINGS_MARIA_DB_USER}' already exists."
else
  echo "👷 Creating user '${BOOKINGS_MARIA_DB_USER}'..."
  mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$ROOT_USER" -p"$ROOT_PASS" -e "CREATE USER '${BOOKINGS_MARIA_DB_USER}'@'%' IDENTIFIED BY '${BOOKINGS_MARIA_DB_PASSWORD}';"
  mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$ROOT_USER" -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO '${BOOKINGS_MARIA_DB_USER}'@'%'; FLUSH PRIVILEGES;"
  echo "✅ User created and granted privileges."
fi

# Проверка соединения к MariaDB
echo "🔐 Verifying connection to MariaDB..."
mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$BOOKINGS_MARIA_DB_USER" -p"$BOOKINGS_MARIA_DB_PASSWORD" -e "SELECT 1;" > /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Unable to connect to MariaDB."
  exit 1
fi

# Проверка и создание базы данных
echo "🔍 Checking if database '${BOOKINGS_MARIA_DB_NAME}' exists..."
DB_EXISTS=$(mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$BOOKINGS_MARIA_DB_USER" -p"$BOOKINGS_MARIA_DB_PASSWORD" -sse "SHOW DATABASES LIKE '${BOOKINGS_MARIA_DB_NAME}';")

if [ "$DB_EXISTS" != "$BOOKINGS_MARIA_DB_NAME" ]; then
  echo "🛠 Creating database '${BOOKINGS_MARIA_DB_NAME}'..."
  mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$BOOKINGS_MARIA_DB_USER" -p"$BOOKINGS_MARIA_DB_PASSWORD" -e "CREATE DATABASE ${BOOKINGS_MARIA_DB_NAME};"
  echo "✅ Database created."
else
  echo "📦 Database '${BOOKINGS_MARIA_DB_NAME}' already exists."
fi

# Проверка существования таблицы
echo "🔍 Checking if table 'bookings' exists..."
TABLE_EXISTS=$(mysql -h "$BOOKINGS_MARIA_DB_HOST" -P "$BOOKINGS_MARIA_DB_PORT_INNER" -u "$BOOKINGS_MARIA_DB_USER" -p"$BOOKINGS_MARIA_DB_PASSWORD" -D "$BOOKINGS_MARIA_DB_NAME" -sse "SHOW TABLES LIKE 'bookings';")

if [ "$TABLE_EXISTS" = "${BOOKINGS_MARIA_DB_NAME}" ]; then
  echo "📋 Table 'bookings' already exists. Skipping migrations."
else
  echo "📄 Running Liquibase migrations..."
  export LIQUIBASE_CLASSPATH="/app/libs/mysql-connector-java-8.0.33.jar"
  liquibase \
    --driver=org.mariadb.jdbc.Driver \
    --url="jdbc:mariadb://${BOOKINGS_MARIA_DB_HOST}:${BOOKINGS_MARIA_DB_PORT_INNER}/${BOOKINGS_MARIA_DB_NAME}" \
    --username="${BOOKINGS_MARIA_DB_USER}" \
    --password="${BOOKINGS_MARIA_DB_PASSWORD}" \
    --changeLogFile="/src/main/resources/db/changelog/db.changelog.yaml" \
    update
fi

# Запуск приложения (переданный через "--" аргумент: java -jar ...)
echo "🚀 Starting bookings-service..."
exec "$@"
