# MySQL Named Volumes Example

This example demonstrates **Named Volumes** in Docker - volumes that are managed entirely by Docker and stored in Docker's internal directory structure.

## What are Named Volumes?

Named volumes are Docker-managed storage locations that:
- Are managed by Docker daemon
- Stored in Docker's internal directory (`/var/lib/docker/volumes/`)
- Persist data independently of container lifecycle
- Provide better portability across different hosts
- Are optimized for Docker's storage drivers

## Files in this Example

```
mysql-named-volumes/
├── docker-compose.yml      # Compose configuration with named volume
├── demo.sh                 # Demonstration script
├── init/
│   ├── 01-schema.sql      # Database schema
│   └── 02-data.sql        # Sample data
└── README.md              # This file
```

## Key Configuration

### Docker Compose Volume Definition
```yaml
volumes:
  mysql_data:
    driver: local
```

### Service Volume Mount
```yaml
services:
  mysql:
    volumes:
      - mysql_data:/var/lib/mysql  # Named volume
      - ./init:/docker-entrypoint-initdb.d:ro  # Bind mount for init scripts
```

## Running the Example

### Quick Start
```bash
# Start MySQL with named volume
docker-compose up -d

# Check volume creation
docker volume ls

# Run demo script
./demo.sh
```

### Manual Steps

1. **Start MySQL:**
   ```bash
   docker-compose up -d mysql
   ```

2. **Inspect the named volume:**
   ```bash
   docker volume ls
   docker volume inspect mysql-named-volumes_mysql_data
   ```

3. **Connect and verify data:**
   ```bash
   docker-compose exec mysql mysql -u root -prootpassword testdb
   ```

4. **Test persistence:**
   ```bash
   # Stop container
   docker-compose stop mysql
   
   # Volume still exists
   docker volume ls
   
   # Restart container
   docker-compose up -d mysql
   
   # Data still there
   docker-compose exec mysql mysql -u root -prootpassword testdb -e "SELECT * FROM users;"
   ```

## Named Volume Characteristics

### ✅ Advantages
- **Docker-managed**: Automatic cleanup and optimization
- **Portable**: Easy to backup, restore, and migrate
- **Performance**: Optimized for container I/O
- **Security**: Isolated from host filesystem
- **Simplicity**: No need to manage host directories

### ⚠️ Considerations
- **Less accessible**: Cannot easily browse files from host
- **Location**: Files stored in Docker's internal directory
- **Debugging**: Requires Docker commands to inspect content

## Volume Operations

### Backup Named Volume
```bash
# Create backup
docker run --rm -v mysql-named-volumes_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .

# Restore backup
docker run --rm -v mysql-named-volumes_mysql_data:/data -v $(pwd):/backup alpine tar xzf /backup/backup.tar.gz -C /data
```

### Volume Information
```bash
# List volumes
docker volume ls

# Inspect volume details
docker volume inspect mysql-named-volumes_mysql_data

# Check volume usage
docker system df -v
```

### Cleanup
```bash
# Stop and remove containers
docker-compose down

# Remove containers and volumes
docker-compose down -v

# Remove specific volume
docker volume rm mysql-named-volumes_mysql_data
```

## When to Use Named Volumes

Named volumes are ideal for:
- **Database storage** (MySQL, PostgreSQL, MongoDB)
- **Application data** that doesn't need host access
- **Shared storage** between multiple containers
- **Production environments** requiring data persistence
- **Portable deployments** across different hosts

## Schema and Data

This example creates:
- **Users table** with sample user data
- **Posts table** linked to users
- **Indexes** for performance optimization
- **Sample data** demonstrating relationships

The data persists across container restarts and demonstrates the reliability of named volumes for database storage.