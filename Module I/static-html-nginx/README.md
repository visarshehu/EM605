# Static HTML with Nginx

This project demonstrates how to create a Docker container that serves a static HTML page using nginx.

## Files

- `index.html` - A simple HTML page with a "Hello World" message
- `Dockerfile` - Docker configuration that uses nginx:alpine as base image and copies the HTML file to the web directory

## How to Build and Run

### Build the Docker Image
```bash
docker build -t static-html-nginx .
```

### Run the Container
```bash
docker run -d -p 8080:80 --name my-static-site static-html-nginx
```

### Access the Website
Open your browser and navigate to: `http://localhost:8080`

### Stop and Remove Container
```bash
docker stop my-static-site
docker rm my-static-site
```

## What This Demonstrates

- Creating a Dockerfile
- Using a base image (nginx:alpine)
- Copying files into a container
- Exposing ports
- Building and running containers
- Port mapping between host and container