# ASP.NET Core Web Application in Docker

This project demonstrates how to containerize an ASP.NET Core web application using Docker with a multi-stage build process.

## Prerequisites

- Docker Desktop installed
- .NET 8.0 SDK (for local development, not required for Docker build)

## Project Files

- `Program.cs` - Minimal ASP.NET Core application with Hello World endpoint
- `HelloWorldApp.csproj` - Project file targeting .NET 8.0
- `Dockerfile` - Multi-stage Docker build configuration

## Dockerfile Analysis

The Dockerfile uses a **multi-stage build** approach:

### Stage 1: Build Stage
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
```
- Uses the full .NET SDK image (larger, contains build tools)
- Copies project file and restores NuGet packages
- Builds and publishes the application in Release mode

### Stage 2: Runtime Stage
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
```
- Uses the smaller ASP.NET runtime image (no build tools)
- Copies only the published application from the build stage
- Sets up the runtime environment

### Key Benefits:
- **Smaller final image**: Runtime image excludes build tools and source code
- **Security**: Final image contains only what's needed to run the app
- **Performance**: Faster container startup and reduced attack surface

## How to Build and Run

### Build the Docker Image
```bash
docker build -t aspnet-hello-world .
```

### Run the Container
```bash
docker run -d -p 8080:8080 --name aspnet-app aspnet-hello-world
```

### Test the Application
```bash
# Hello World endpoint
curl http://localhost:8080

# Health check endpoint
curl http://localhost:8080/health
```

### View Container Logs
```bash
docker logs aspnet-app
```

### Stop and Remove Container
```bash
docker stop aspnet-app
docker rm aspnet-app
```

## What This Demonstrates

- **Multi-stage Docker builds** for .NET applications
- **Image optimization** (build vs. runtime images)
- **Port configuration** for ASP.NET Core in containers
- **Environment variables** for ASP.NET Core configuration
- **Minimal API** pattern in .NET 8
- **Container health checks** and monitoring endpoints

## Development Notes

- The application listens on port 8080 inside the container
- Environment variable `ASPNETCORE_URLS` configures the listening address
- The health endpoint provides basic application status information