# Multi-Container Todo Application

This project demonstrates a multi-container application architecture using Docker **without** Docker Compose. The application consists of three containers:

1. **MySQL Database** - Data storage
2. **Node.js Backend** - REST API server
3. **React Frontend** - User interface

## Architecture Overview

```
Frontend (React/Nginx) -> Backend (Node.js/Express) -> Database (MySQL)
     Port 3000                Port 3001                   Port 3306
```

## Project Structure

```
multi-container-todo-app/
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   ├── public/
│   └── src/
├── database/
│   └── init.sql
└── README.md
```

## Manual Container Orchestration

### Step 1: Create Docker Network

Create a custom bridge network to allow containers to communicate:

```bash
docker network create todo-network
```

### Step 2: Start MySQL Database Container

```bash
docker run -d \
  --name mysql-container \
  --network todo-network \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=todoapp \
  -v $(pwd)/database/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 3306:3306 \
  mysql:8.0
```

Wait for MySQL to initialize (check logs):
```bash
docker logs mysql-container
```

### Step 3: Build and Start Backend Container

Build the backend image:
```bash
cd backend
docker build -t todo-backend .
cd ..
```

Run the backend container:
```bash
docker run -d \
  --name backend-container \
  --network todo-network \
  -e DB_HOST=mysql-container \
  -e DB_USER=root \
  -e DB_PASSWORD=rootpassword \
  -e DB_NAME=todoapp \
  -p 3001:3000 \
  todo-backend
```

### Step 4: Build and Start Frontend Container

Build the frontend image:
```bash
cd frontend
docker build -t todo-frontend .
cd ..
```

Run the frontend container:
```bash
docker run -d \
  --name frontend-container \
  --network todo-network \
  -p 3000:80 \
  todo-frontend
```

## Accessing the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001/api/todos
- **Backend Health**: http://localhost:3001/health

## Container Management Commands

### View Running Containers
```bash
docker ps
```

### View Container Logs
```bash
docker logs mysql-container
docker logs backend-container
docker logs frontend-container
```

### Stop and Remove All Containers
```bash
docker stop frontend-container backend-container mysql-container
docker rm frontend-container backend-container mysql-container
docker network rm todo-network
```

### Restart Individual Containers
```bash
docker restart mysql-container
docker restart backend-container
docker restart frontend-container
```

## Container Communication

### Network Architecture
- All containers are connected via the `todo-network` bridge network
- Containers can communicate using container names as hostnames
- MySQL is accessible as `mysql-container:3306` from backend
- Backend is accessible as `backend-container:3000` from frontend

### Environment Variables
- **Backend**: Configured with database connection parameters
- **Frontend**: Uses nginx proxy to route API calls to backend

## Key Docker Concepts Demonstrated

### 1. Custom Networks
- Creating and using custom bridge networks
- Container-to-container communication using names
- Network isolation and security

### 2. Environment Variables
- Configuring applications through environment variables
- Database connection configuration
- Service discovery through hostnames

### 3. Volume Mounting
- Mounting SQL initialization scripts
- Data persistence and initialization

### 4. Multi-stage Builds
- Frontend uses multi-stage build (build → production)
- Optimized image sizes and separation of concerns

### 5. Port Mapping
- Exposing container services to host system
- Service accessibility and load balancing

### 6. Container Dependencies
- Managing startup order manually
- Health checks and retry logic
- Service discovery and communication

## Development Workflow

### Making Changes

**Backend Changes:**
1. Stop backend container: `docker stop backend-container`
2. Remove container: `docker rm backend-container`
3. Rebuild image: `docker build -t todo-backend ./backend`
4. Start new container with same configuration

**Frontend Changes:**
1. Stop frontend container: `docker stop frontend-container`
2. Remove container: `docker rm frontend-container`
3. Rebuild image: `docker build -t todo-frontend ./frontend`
4. Start new container with same configuration

### Database Changes
1. Update `database/init.sql`
2. Remove MySQL container and its data
3. Start fresh MySQL container

## Troubleshooting

### Common Issues

1. **Backend can't connect to database**
   - Check if MySQL container is running
   - Verify network connectivity
   - Check environment variables

2. **Frontend can't reach backend**
   - Verify backend container is running
   - Check nginx configuration
   - Verify network configuration

3. **Port conflicts**
   - Ensure ports 3000, 3001, 3306 are available
   - Use different host ports if needed

### Debugging Commands
```bash
# Check network configuration
docker network inspect todo-network

# Execute commands inside containers
docker exec -it mysql-container mysql -u root -p
docker exec -it backend-container sh
docker exec -it frontend-container sh

# Check container resource usage
docker stats
```

## What This Demonstrates

This example showcases manual container orchestration and the challenges it presents:

- **Manual dependency management** - Starting containers in correct order
- **Network configuration** - Setting up container communication
- **Service discovery** - Using container names as hostnames
- **Environment configuration** - Managing different environments
- **Debugging complexity** - Troubleshooting multi-container applications
- **Scaling limitations** - Manual scaling and load balancing

This experience highlights why orchestration tools like Docker Compose and Kubernetes are valuable for managing multi-container applications!