FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/order-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "/app.jar"]