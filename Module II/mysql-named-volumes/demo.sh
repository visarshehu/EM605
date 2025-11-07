#!/bin/bash

echo "=== MySQL Named Volumes Demo ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}1. Starting MySQL with Named Volume...${NC}"
docker-compose up -d mysql

echo
echo -e "${BLUE}2. Waiting for MySQL to be healthy...${NC}"
sleep 10

echo
echo -e "${BLUE}3. Showing Docker volumes...${NC}"
docker volume ls | grep mysql

echo
echo -e "${BLUE}4. Inspecting the named volume...${NC}"
docker volume inspect mysql-named-volumes_mysql_data

echo
echo -e "${BLUE}5. Running MySQL client to show data...${NC}"
docker-compose up mysql-client

echo
echo -e "${YELLOW}6. Stopping containers but keeping volume...${NC}"
docker-compose stop

echo
echo -e "${BLUE}7. Volume still exists after container stop:${NC}"
docker volume ls | grep mysql

echo
echo -e "${YELLOW}8. Restarting MySQL - data should persist...${NC}"
docker-compose up -d mysql
sleep 10

echo
echo -e "${BLUE}9. Verifying data persistence...${NC}"
docker-compose exec mysql mysql -u root -prootpassword testdb -e "SELECT COUNT(*) as 'Users in Named Volume' FROM users;"

echo
echo -e "${GREEN}10. Named Volume Demo Complete!${NC}"
echo -e "${YELLOW}To clean up: docker-compose down -v${NC}"