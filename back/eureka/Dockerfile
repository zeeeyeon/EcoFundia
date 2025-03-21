FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/eureka-0.0.1-SNAPSHOT.jar
RUN chown jenkins:jenkins /app.jar && chmod 755 /app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "/app.jar"]

