# Docker Compose Todo Application

This project demonstrates multi-container application orchestration using **Docker Compose**. The application consists of the same three services as Module I, but now managed through Docker Compose for simplified deployment and management.

## Architecture Overview

```
Frontend (React/Nginx) ←→ Backend (Node.js/Express) ←→ Database (MySQL)
     Port 3000                Port 3001                   Port 3306
```

## Project Structure

```
docker-compose-todo-app/
├── docker-compose.yml          # Production configuration
├── docker-compose.dev.yml      # Development overrides
├── .env                        # Environment variables
├── .env.example               # Environment template
├── .dockerignore              # Docker ignore rules
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

## Key Docker Compose Features Demonstrated

### 1. Service Dependencies
```yaml
depends_on:
  mysql:
    condition: service_healthy
```

### 2. Health Checks
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  timeout: 20s
  retries: 10
```

### 3. Named Volumes
```yaml
volumes:
  mysql_data:
    driver: local
```

### 4. Custom Networks
```yaml
networks:
  todo-network:
    driver: bridge
```

### 5. Environment Variables
```yaml
environment:
  - DB_HOST=mysql
  - DB_USER=${DB_USER:-root}
```

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Ports 3000, 3001, 3306 available

### Production Deployment

1. **Clone and navigate to the project:**
   ```bash
   cd "Module II/docker-compose-todo-app"
   ```

2. **Start all services:**
   ```bash
   docker-compose up -d
   ```

3. **Check service status:**
   ```bash
   docker-compose ps
   ```

4. **Access the application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001/api/todos
   - Backend Health: http://localhost:3001/health

### Development Mode

For development with hot reloading and additional tools:

```bash
# Start in development mode
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Access additional services
# - Adminer (Database GUI): http://localhost:8080
```

## Docker Compose Commands

### Basic Operations
```bash
# Start services in background
docker-compose up -d

# Start services with logs
docker-compose up

# Stop services
docker-compose down

# Stop services and remove volumes
docker-compose down -v

# Restart specific service
docker-compose restart backend
```

### Development Operations
```bash
# Build and start
docker-compose up --build

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql

# Execute commands in containers
docker-compose exec backend sh
docker-compose exec mysql mysql -u root -p todoapp
```

### Scaling Operations
```bash
# Scale backend service
docker-compose up -d --scale backend=3

# View scaled services
docker-compose ps
```

## Environment Configuration

### Production (.env)
```env
DB_USER=root
DB_PASSWORD=rootpassword
DB_NAME=todoapp
NODE_ENV=production
```

### Development (.env with dev overrides)
```env
DB_USER=devuser
DB_PASSWORD=devpassword
DB_NAME=todoapp_dev
NODE_ENV=development
```

## Service Communication

### Network Architecture
- All services communicate through the `todo-network`
- Services use service names as hostnames
- No port mapping needed for inter-service communication

### Service Discovery
```yaml
# Backend connects to database using service name
DB_HOST=mysql

# Frontend proxy routes to backend using service name
proxy_pass http://backend:3000;
```

## Data Persistence

### Named Volumes
- `mysql_data`: Persists database data across container restarts
- Survives `docker-compose down` but not `docker-compose down -v`

### Volume Management
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect docker-compose-todo-app_mysql_data

# Backup database
docker-compose exec mysql mysqldump -u root -p todoapp > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u root -p todoapp < backup.sql
```

## Monitoring and Health Checks

### Built-in Health Checks
All services include health checks that:
- Monitor service availability
- Enable proper startup ordering
- Support container orchestration

### Monitoring Commands
```bash
# Check service health
docker-compose ps

# View health check logs
docker inspect todo-mysql --format='{{json .State.Health}}'

# Monitor resource usage
docker stats
```

## Comparison with Manual Container Management

| Aspect | Manual (Module I) | Docker Compose (Module II) |
|--------|-------------------|----------------------------|
| **Startup** | Multiple commands, manual order | Single command, automatic order |
| **Networking** | Manual network creation | Automatic network management |
| **Dependencies** | Manual timing/health checks | Built-in dependency management |
| **Environment** | Manual env var management | Centralized .env files |
| **Scaling** | Manual container management | Simple scaling commands |
| **Updates** | Stop/remove/rebuild manually | `docker-compose up --build` |
| **Logs** | Individual docker logs commands | Centralized log management |
| **Cleanup** | Manual container/network removal | `docker-compose down` |

## Advanced Features

### Multi-File Composition
```bash
# Combine base + development overrides
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Combine base + production overrides
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### Service Profiles
```yaml
# In docker-compose.dev.yml
adminer:
  profiles: ["dev", "debug"]
```

```bash
# Start with specific profile
docker-compose --profile dev up
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '0.50'
      memory: 512M
    reservations:
      memory: 256M
```

## Troubleshooting

### Common Issues

1. **Services won't start**
   ```bash
   # Check logs
   docker-compose logs
   
   # Check service status
   docker-compose ps
   ```

2. **Database connection issues**
   ```bash
   # Verify MySQL is healthy
   docker-compose ps mysql
   
   # Check backend logs
   docker-compose logs backend
   ```

3. **Port conflicts**
   ```bash
   # Use different ports in .env or docker-compose.yml
   # Or stop conflicting services
   sudo lsof -i :3000
   ```

### Debugging Commands
```bash
# Enter running containers
docker-compose exec mysql bash
docker-compose exec backend sh
docker-compose exec frontend sh

# Check network configuration
docker network ls
docker network inspect docker-compose-todo-app_todo-network

# Verify environment variables
docker-compose config
```

## Security Considerations

### Implemented Security Measures
- Non-root users in containers
- Resource limits and health checks
- Network isolation
- Security headers in nginx
- Environment variable management

### Production Recommendations
- Use Docker secrets for sensitive data
- Implement proper backup strategies
- Use container scanning tools
- Regular security updates
- Monitor container logs

## What This Demonstrates

Docker Compose showcases significant improvements over manual container management:

### **Simplified Orchestration**
- Single-command deployment
- Automatic service ordering
- Built-in health checks

### **Configuration Management**
- Environment variable management
- Multi-file composition
- Service profiles

### **Development Workflow**
- Hot reloading support
- Development vs production configurations
- Additional development tools (Adminer)

### **Operational Benefits**
- Centralized logging
- Easy scaling
- Graceful shutdowns
- Data persistence

This demonstrates why Docker Compose is the preferred tool for multi-container application development and deployment!