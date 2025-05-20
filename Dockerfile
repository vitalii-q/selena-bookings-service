# Используем официальный образ с OpenJDK
FROM openjdk:17-jdk-slim

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем весь проект для выполнения тестов
#COPY . /app

# Копируем файл jar в контейнер (обрати внимание на имя jar-файла)
COPY target/bookings-service-0.0.1-SNAPSHOT.jar /app/app.jar

# Устанавливаем Maven (если он не установлен в базовом образе)
#RUN apt-get update && apt-get install -y maven

# Запускаем тесты с помощью Maven (аналог команды `go test`)
#RUN mvn test

# Открываем порт для контейнера (например, 8080)
EXPOSE 9066

# Запускаем Spring Boot приложение
ENTRYPOINT ["java", "-jar", "app.jar"]