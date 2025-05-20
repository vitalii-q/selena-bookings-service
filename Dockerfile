# booking-service/Dockerfile

# --- Stage 1: Сборка JAR ---
FROM maven:3.9.5-eclipse-temurin-17 AS builder

RUN echo "🔥 Используется Dockerfile"

RUN apt-get update && apt-get install -y default-mysql-client

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем весь проект
COPY . /app

RUN mvn clean package -DskipTests


# --- Stage 2: Продакшн образ ---
FROM openjdk:17-jdk-slim

WORKDIR /app

# Копируем файл jar в контейнер
COPY --from=builder /app/target/bookings-service-0.0.1-SNAPSHOT.jar app.jar

# Устанавливаем Maven (если он не установлен в базовом образе)
#RUN apt-get update && apt-get install -y maven

# Запускаем тесты с помощью Maven (аналог команды `go test`)
#RUN mvn test

# Открываем порт для контейнера (например, 8080)
#EXPOSE 9066

# Запускаем Spring Boot приложение
ENTRYPOINT ["java", "-jar", "app.jar"]