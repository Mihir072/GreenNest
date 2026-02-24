# -------- Stage 1: Build --------
FROM maven:3.8.5-openjdk-17 AS build

# Set working directory inside the container
WORKDIR /app

# Copy pom.xml and source code
COPY Backend/pom.xml .
COPY Backend/src ./src

# Build the Spring Boot app
RUN mvn clean package -DskipTests

# -------- Stage 2: Run --------
FROM openjdk:17.0.1-jdk-slim

# Set working directory
WORKDIR /app

# Copy the built JAR from the previous stage
COPY --from=build /app/target/GreenNest-Backend-0.0.1-SNAPSHOT.jar app.jar

# Expose port (Render will map this)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

# Run the JAR with Render's PORT environment variable
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=${PORT:-8080}"]
