#!/bin/bash

echo "=== MySQL Bind Mounts Demo ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}1. Checking bind mount directory before start...${NC}"
ls -la ./mysql-data/

echo
echo -e "${BLUE}2. Starting MySQL with Bind Mount...${NC}"
docker-compose up -d mysql

echo
echo -e "${BLUE}3. Waiting for MySQL to be healthy...${NC}"
sleep 15

echo
echo -e "${BLUE}4. Showing files created in bind mount directory...${NC}"
ls -la ./mysql-data/

echo
echo -e "${BLUE}5. Running MySQL client to show data and create backup...${NC}"
docker-compose up mysql-client

echo
echo -e "${BLUE}6. Checking backup file created via bind mount...${NC}"
ls -la ./backups/

echo
echo -e "${BLUE}7. Viewing backup file content (first 20 lines)...${NC}"
head -20 ./backups/testdb_backup.sql 2>/dev/null || echo "Backup file not ready yet..."

echo
echo -e "${YELLOW}8. Stopping containers...${NC}"
docker-compose stop

echo
echo -e "${BLUE}9. Data files still exist in host directory after container stop:${NC}"
ls -la ./mysql-data/ | wc -l
echo "Files in mysql-data directory: $(ls ./mysql-data/ | wc -l)"

echo
echo -e "${YELLOW}10. Restarting MySQL - data should persist from host directory...${NC}"
docker-compose up -d mysql
sleep 10

echo
echo -e "${BLUE}11. Verifying data persistence from bind mount...${NC}"
docker-compose exec mysql mysql -u root -prootpassword testdb -e "SELECT COUNT(*) as 'Products in Bind Mount' FROM products;"

echo
echo -e "${BLUE}12. Demonstrating host accessibility - modifying files directly...${NC}"
echo "# Custom log comment added from host" >> ./mysql-data/general.log 2>/dev/null || echo "Log file not accessible yet"

echo
echo -e "${GREEN}13. Bind Mount Demo Complete!${NC}"
echo -e "${YELLOW}To clean up: docker-compose down${NC}"
echo -e "${YELLOW}Data persists in ./mysql-data/ directory${NC}"