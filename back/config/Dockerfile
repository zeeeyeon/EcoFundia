FROM openjdk:17-jdk-slim AS build
WORKDIR /app
COPY gradlew gradlew.bat settings.gradle build.gradle ./
RUN chmod +x gradlew
RUN ./gradlew build --no-daemon
FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} app.jar
EXPOSE 9000
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
