FROM openjdk:17-slim-bullseye AS build

# Set the working directory in the container
WORKDIR /app

# Copy the Maven wrapper files
COPY mvnw .
COPY .mvn .mvn

# Copy the project files
COPY pom.xml .
COPY src src

# Allow Maven to download dependencies
#RUN ./mvnw dependency:go-offline

# Package the application
RUN ./mvnw package

# Stage 2: Create a lightweight image to host the application
FROM openjdk:17-alpine3.14

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file from the build stage to the new stage
COPY --from=build /app/target/*.jar ./app.jar

# Create a non-root user
RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

# Change ownership of the application files to the non-root user
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8080

# Run the Spring Boot application
CMD ["java", "-jar", "app.jar"]

