#!/bin/bash

# Проверяем, доступна ли база данных MariaDB
MAX_ATTEMPTS=10
attempt=1

until mysql -h maria-db -u root -ppassword -e "SELECT 1" > /dev/null 2>&1; do
  if [ $attempt -ge $MAX_ATTEMPTS ]; then
    echo "ERROR: MariaDB is still unavailable after $attempt attempts. Exiting script."
    exit 1
  fi

  echo "Waiting for MariaDB to be available... (attempt $attempt/$MAX_ATTEMPTS)"
  attempt=$((attempt + 1))
  sleep 3
done

echo "MariaDB is available!"

# Передаем управление команде, которая передается после '--' в docker-compose.yml
# (в твоём случае — запуск Spring Boot)
exec "${@:2}"

# После того как база данных доступна, запускаем Spring Boot приложение
#if [ "$SPRING_PROFILES_ACTIVE" = "dev" ]; then
#  echo "Running in dev mode: starting Spring Boot with Maven"
#  ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
#else
#  echo "Running in prod mode: starting Spring Boot from jar"
#  java -jar /app.jar
#fi
