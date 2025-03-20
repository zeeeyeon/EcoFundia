FROM openjdk:17-jdk-slim AS build
WORKDIR /app
COPY gradlew gradlew.bat settings.gradle build.gradle ./
COPY gradle/ gradle/
RUN chmod +x gradlew
RUN ./gradlew clean build --no-daemon
FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/config-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 9000
ENTRYPOINT ["java", "-jar", "/app.jar"]
