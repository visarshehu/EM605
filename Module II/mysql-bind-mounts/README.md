# MySQL Bind Mounts Example

This example demonstrates **Bind Mounts** in Docker - direct mounting of host directories into containers, providing full host filesystem access.

## What are Bind Mounts?

Bind mounts are direct mappings between host directories and container paths that:
- Mount host directories/files directly into containers
- Provide real-time, bidirectional file synchronization
- Allow direct host access to container data
- Use absolute or relative paths on the host
- Are not managed by Docker daemon

## Files in this Example

```
mysql-bind-mounts/
├── docker-compose.yml      # Compose configuration with bind mounts
├── demo.sh                 # Demonstration script
├── mysql-data/            # Host directory for MySQL data (created on first run)
├── backups/               # Host directory for database backups
├── config/
│   └── mysql.cnf          # Custom MySQL configuration
├── init/
│   ├── 01-schema.sql      # Database schema
│   └── 02-data.sql        # Sample data
└── README.md              # This file
```

## Key Configuration

### Docker Compose Bind Mount Definition
```yaml
services:
  mysql:
    volumes:
      # Bind mount for MySQL data
      - ./mysql-data:/var/lib/mysql
      # Bind mount for init scripts
      - ./init:/docker-entrypoint-initdb.d:ro
      # Bind mount for configuration
      - ./config:/etc/mysql/conf.d:ro
      
  mysql-client:
    volumes:
      # Bind mount for backups
      - ./backups:/backups
```

## Running the Example

### Quick Start
```bash
# Start MySQL with bind mounts
docker-compose up -d

# Check host directories
ls -la mysql-data/
ls -la backups/

# Run demo script
./demo.sh
```

### Manual Steps

1. **Start MySQL:**
   ```bash
   docker-compose up -d mysql
   ```

2. **Observe host directory creation:**
   ```bash
   ls -la ./mysql-data/
   # MySQL files are now visible on host
   ```

3. **Create database backup:**
   ```bash
   docker-compose exec mysql mysqldump -u root -prootpassword testdb > ./backups/backup.sql
   ```

4. **View files directly on host:**
   ```bash
   # View MySQL data files
   ls -la ./mysql-data/
   
   # View backup file
   cat ./backups/backup.sql
   ```

5. **Test persistence:**
   ```bash
   # Stop container
   docker-compose stop mysql
   
   # Data files still in host directory
   ls ./mysql-data/
   
   # Restart container
   docker-compose up -d mysql
   
   # Data persists from host directory
   docker-compose exec mysql mysql -u root -prootpassword testdb -e "SELECT * FROM products LIMIT 5;"
   ```

## Bind Mount Characteristics

### ✅ Advantages
- **Direct access**: View/edit files from host filesystem
- **Real-time sync**: Changes reflect immediately
- **Easy backup**: Standard file operations work
- **Development friendly**: Hot reloading, live editing
- **Debugging**: Direct log file access
- **Integration**: Easy CI/CD and monitoring tool access

### ⚠️ Considerations
- **Path dependency**: Requires specific host directory structure
- **Permissions**: May have host/container user ID conflicts
- **Security**: Exposes host filesystem to containers
- **Portability**: Less portable across different hosts
- **Performance**: May be slower than volumes on some platforms

## Practical Examples

### Database Backup and Restore
```bash
# Create backup using bind mount
docker-compose exec mysql mysqldump -u root -prootpassword testdb > ./backups/$(date +%Y%m%d_%H%M%S)_backup.sql

# Restore from backup
docker-compose exec -T mysql mysql -u root -prootpassword testdb < ./backups/backup.sql
```

### Configuration Management
```bash
# Edit MySQL config directly on host
nano ./config/mysql.cnf

# Restart MySQL to apply changes
docker-compose restart mysql
```

### Log Monitoring
```bash
# View MySQL logs directly from host
tail -f ./mysql-data/general.log

# Monitor slow queries
tail -f ./mysql-data/slow.log
```

### Development Workflow
```bash
# Make changes to init scripts
echo "INSERT INTO products (name, price) VALUES ('New Product', 99.99);" >> ./init/03-additional-data.sql

# Restart to apply changes
docker-compose down
docker-compose up -d
```

## Security Considerations

### File Permissions
```bash
# Set appropriate permissions
chmod 755 ./mysql-data
chmod 644 ./config/mysql.cnf

# Handle user ID mapping if needed
sudo chown -R $(id -u):$(id -g) ./mysql-data
```

### Access Control
- Limit bind mount scope to necessary directories only
- Use read-only mounts when possible (`:ro` suffix)
- Avoid mounting sensitive host directories
- Consider using Docker secrets for sensitive data

## When to Use Bind Mounts

Bind mounts are ideal for:
- **Development environments** requiring live file editing
- **Configuration files** that change frequently
- **Log monitoring** and real-time analysis
- **Backup and restore operations**
- **Integration** with host-based tools
- **Shared development** where team members need file access

## Schema and Data

This example creates an e-commerce database with:
- **Categories** and **Products** tables
- **Orders** and **Order Items** for transaction tracking
- **Indexes** for query performance
- **Sample data** representing a product catalog

All data is directly accessible through the `./mysql-data/` directory on the host system.

## Cleanup

```bash
# Stop containers
docker-compose down

# Remove data (optional - deletes host files!)
rm -rf ./mysql-data/
rm -f ./backups/*.sql
```

**Note**: Unlike named volumes, bind mount data persists on the host filesystem even after `docker-compose down -v`.