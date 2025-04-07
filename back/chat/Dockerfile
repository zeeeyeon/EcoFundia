FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/chat-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 8087
ENTRYPOINT ["java", "-jar", "/app.jar"]