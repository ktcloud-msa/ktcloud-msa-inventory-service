FROM eclipse-temurin:23-jdk AS build
WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

COPY client-redis/build.gradle.kts client-redis/
COPY common/build.gradle.kts common/
COPY inventory-event/build.gradle.kts inventory-event/
COPY inventory-service/build.gradle.kts inventory-service/
COPY inventory/build.gradle.kts inventory/

RUN ./gradlew dependencies --no-daemon

COPY . .

RUN ./gradlew :inventory-service:bootJar -x test --no-daemon

FROM eclipse-temurin:23-jre
WORKDIR /app

RUN useradd -ms /bin/bash springuser
USER springuser

COPY --from=build /app/inventory-service/build/libs/inventory-service.jar app.jar

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=staging", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "app.jar"]

EXPOSE 8080