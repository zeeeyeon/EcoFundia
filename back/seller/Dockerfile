FROM openjdk:17-jdk-slim
ARG JAR_FILE=build/libs/seller-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
EXPOSE [해당 서비스 포트번호]
ENTRYPOINT ["java", "-jar", "/app.jar"]