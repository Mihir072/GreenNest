# -------- Stage 1: Build --------
FROM maven:3.8.5-openjdk-17 AS build

# Set working directory inside the container
WORKDIR /app

# Copy only app folder (which contains pom.xml)
COPY Green-Harbor-Backend /app

# Build the Spring Boot app
RUN mvn clean package -DskipTests

# -------- Stage 2: Run --------
FROM openjdk:17.0.1-jdk-slim

# Copy the built JAR from the previous stage
COPY --from=build /app/target/GreenNest-Backend-0.0.1-SNAPSHOT.jar app.jar

# Expose port
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
