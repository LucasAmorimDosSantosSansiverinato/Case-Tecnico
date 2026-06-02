FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn dependency:resolve -q

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /root/.m2 /root/.m2
COPY --from=build /app .
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*
CMD ["mvn", "flyway:migrate"]
