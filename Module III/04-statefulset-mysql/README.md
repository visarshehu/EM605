# Simple MySQL Deployment

This example demonstrates a basic Kubernetes Deployment running a single MySQL instance with hardcoded credentials.

## What is a Deployment for Databases?

While StatefulSets are typically used for databases in production, this example uses a simple Deployment to demonstrate:
- **Basic database deployment** - Single MySQL instance
- **Hardcoded credentials** - Simple configuration for learning
- **No persistent storage** - Data is lost when pod restarts
- **Service exposure** - Basic database connectivity

## Files in this Example

```
04-statefulset-mysql/
├── mysql-deployment.yaml     # Simple MySQL Deployment
├── mysql-services.yaml       # Service for database access
└── README.md                 # This file
```

## Architecture Overview

```
┌─────────────────┐
│  MySQL Pod      │
│  (Deployment)   │
│  No storage     │
└─────────────────┘
         │
┌─────────────────┐
│  mysql-service  │
│   (Service)     │
└─────────────────┘
```

## Key Deployment Features

### 1. Simple Container Configuration
```yaml
containers:
- name: mysql
  image: mysql:8.0
  env:
  - name: MYSQL_ROOT_PASSWORD
    value: "rootpassword"
  - name: MYSQL_DATABASE
    value: "testdb"
  - name: MYSQL_USER
    value: "testuser"
  - name: MYSQL_PASSWORD
    value: "testpassword"
```

## Deployment Instructions

### Prerequisites
- Kubernetes cluster running
- kubectl configured

### Deploy the MySQL Database

1. **Create the Service:**
   ```bash
   kubectl apply -f mysql-services.yaml
   ```

2. **Create the Deployment:**
   ```bash
   kubectl apply -f mysql-deployment.yaml
   ```

3. **Monitor deployment:**
   ```bash
   kubectl get deployment mysql-deployment
   kubectl get pods -l app=mysql
   kubectl get service mysql-service
   ```

## Monitoring the Deployment

### Check Deployment Status
```bash
# View Deployment
kubectl get deployment mysql-deployment -o wide

# Check pod status
kubectl get pods -l app=mysql -o wide

# Check service
kubectl get service mysql-service
```

### View Logs
```bash
# Check MySQL logs
kubectl logs -l app=mysql

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Testing the MySQL Database

### Connect to MySQL
```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Connect to MySQL
kubectl exec -it $POD_NAME -- mysql -u root -prootpassword

# Test the database
mysql> USE testdb;
mysql> SHOW TABLES;
mysql> CREATE TABLE test_table (id INT, name VARCHAR(50));
mysql> INSERT INTO test_table VALUES (1, 'test');
mysql> SELECT * FROM test_table;
```

### Test User Access
```bash
# Connect as the application user
kubectl exec -it $POD_NAME -- mysql -u testuser -ptestpassword testdb

# Test user permissions
mysql> SHOW TABLES;
mysql> SELECT * FROM test_table;
```

## Service Access

### Access via Service
```bash
# Create a test client pod
kubectl run mysql-client --image=mysql:8.0 -it --rm --restart=Never -- \
  mysql -h mysql-service -u root -prootpassword
```

## Troubleshooting

### Common Issues

1. **Pod fails to start:**
   ```bash
   kubectl describe pod $POD_NAME
   kubectl logs $POD_NAME
   ```

2. **Connection refused:**
   ```bash
   # Check if MySQL is ready
   kubectl exec $POD_NAME -- mysqladmin ping -u root -prootpassword
   ```

3. **Service not accessible:**
   ```bash
   kubectl get endpoints mysql-service
   kubectl describe service mysql-service
   ```

## Cleanup

```bash
# Delete deployment and service
kubectl delete deployment mysql-deployment
kubectl delete service mysql-service
```

## Important Notes

⚠️ **This is a simple example for learning purposes only!**

- **No persistent storage** - Data is lost when pod restarts
- **Hardcoded passwords** - Not secure for production use
- **Single replica** - No high availability
- **No backups** - Data can be lost permanently

## Production Considerations

For production databases, consider:
- Using **StatefulSets** instead of Deployments
- Implementing **persistent volumes** for data persistence
- Using **Secrets** for credential management
- Setting up **database replication** for high availability
- Implementing **regular backups**
- Using **MySQL Operators** for advanced management