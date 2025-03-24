FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/gateway-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 9000
ENTRYPOINT ["java", "-jar", "/app.jar"]
