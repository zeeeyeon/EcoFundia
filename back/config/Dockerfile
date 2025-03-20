FROM openjdk:17-jdk-slim AS build
WORKDIR /app
COPY gradlew gradlew.bat settings.gradle build.gradle ./
COPY gradle/wrapper/gradle-wrapper.jar gradle/wrapper/gradle-wrapper.properties ./gradle/wrapper/
RUN chmod +x gradlew
RUN ./gradlew build --no-daemon || { echo 'Gradle build failed'; exit 1; }
FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/config-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar
EXPOSE 9000
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
