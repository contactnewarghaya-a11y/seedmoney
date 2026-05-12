# ---- Stage 1: Build ----
# Use a full Maven + JDK image to compile the Spring Boot project
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy only pom.xml first to leverage Docker layer caching for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the application
COPY src ./src
RUN mvn package -DskipTests -B

# ---- Stage 2: Runtime ----
# Use a minimal JRE to run the compiled JAR - this keeps the image small
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Copy only the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Render.com uses port 8080 by default for web services
EXPOSE 8080

# Start the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
