# Simple Database Initialization Job

This example demonstrates a basic Kubernetes Job that initializes a MySQL database with simple schema and data.

## What is a Kubernetes Job?

A Job creates one or more pods and ensures that a specified number of pods successfully complete. Key characteristics:
- **Run to completion** - Pods run until successful completion
- **Retry logic** - Automatic retries on failure with backoff
- **Parallel execution** - Can run multiple pods in parallel
- **Cleanup control** - Automatic cleanup after completion
- **Failure handling** - Configurable failure policies

## Job Types

### 1. Single Job (completions=1)
- Runs one pod to completion
- Perfect for database migrations, backups

### 2. Parallel Jobs with Fixed Count
- Runs multiple pods with shared work queue
- Each pod processes different data

### 3. Parallel Jobs with Work Queue
- Multiple pods process items from a queue
- Dynamic work distribution

## Files in this Example

```
06-job-db-init/
├── mysql-deployment.yaml       # Simple MySQL deployment and service
├── init-db-job.yaml           # Simple database initialization job
└── README.md                  # This file
```

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐
│ MySQL Deployment│    │  Init DB Job    │
│                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │
│  │   MySQL   │  │    │  │  MySQL    │  │
│  │Container  │  │    │  │  Client   │  │
│  │Port: 3306 │  │    │  │  Script   │  │
│  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
           mysql-service
```

## Key Job Features

### 1. Simple Job Configuration
```yaml
spec:
  template:
    spec:
      containers:
      - name: init-db
        image: mysql:8
        command: ["/bin/sh", "-c"]
        args: [SQL initialization script]
      restartPolicy: Never
      backoffLimit: 3
```

### 2. Hardcoded Database Connection
- Connects directly to `mysql-service`
- Uses hardcoded credentials (for simplicity)
- Creates database, table, and inserts sample data

## Deployment Instructions

1. **Deploy MySQL database:**
   ```bash
   kubectl apply -f mysql-deployment.yaml
   ```

2. **Wait for MySQL to be ready:**
   ```bash
   kubectl wait --for=condition=available deployment/mysql-deployment --timeout=300s
   ```

3. **Run the database initialization job:**
   ```bash
   kubectl apply -f init-db-job.yaml
   ```

4. **Monitor job progress:**
   ```bash
   kubectl get jobs
   kubectl get pods -l job-name=init-db-job
   ```

## Monitoring Job Execution

### Check Job Status
```bash
# View job status
kubectl get job init-db-job

# Check job details
kubectl describe job init-db-job

# View job pod logs
kubectl logs -l job-name=init-db-job
```

### Verify Database Initialization
```bash
# Connect to MySQL and verify data
POD_NAME=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- mysql -u root -p1234567890

# Inside MySQL prompt:
mysql> USE students;
mysql> SELECT * FROM users;
mysql> SHOW TABLES;
```

## Testing the Results

### Manual Database Check
```bash
# Test the database setup
kubectl exec -it deployment/mysql-deployment -- mysql -u root -p1234567890 -e "
  USE students; 
  SELECT * FROM users;
  DESCRIBE users;
"
```

## Cleanup

```bash
# Delete the job
kubectl delete job init-db-job

# Delete MySQL deployment (optional)
kubectl delete deployment mysql-deployment
kubectl delete service mysql-service
```

## Important Notes

⚠️ **This is a simple example for learning purposes!**

- **Hardcoded passwords** - Not secure for production
- **No persistent storage** - Data is lost when MySQL pod restarts  
- **No error handling** - Real jobs should have better error handling
- **No job dependencies** - Job assumes MySQL is ready

## Production Considerations

For production database jobs:
- Use **Secrets** for database credentials
- Implement **proper wait conditions** for dependencies
- Add **comprehensive error handling** and rollback
- Use **persistent volumes** for database storage
- Set appropriate **resource limits** and timeouts
- Implement **job monitoring** and alerting