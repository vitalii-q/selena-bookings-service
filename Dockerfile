# Используем официальный образ с OpenJDK
FROM openjdk:17-jdk-slim

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем файл jar в контейнер (обрати внимание на имя jar-файла)
COPY target/bookings-service.jar /app/bookings-service.jar

# Открываем порт для контейнера (например, 8080)
EXPOSE 8080

# Запускаем Spring Boot приложение
ENTRYPOINT ["java", "-jar", "bookings-service.jar"]
