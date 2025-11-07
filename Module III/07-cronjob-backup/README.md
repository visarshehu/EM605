# Simple Hello CronJob

This example demonstrates a basic Kubernetes CronJob that runs a simple "Hello" message on a schedule.

## What is a CronJob?

A CronJob creates Jobs on a schedule using cron syntax. Key characteristics:
- **Scheduled execution** - Runs jobs based on cron expressions
- **Job history management** - Keeps track of successful and failed jobs
- **Concurrency control** - Manages overlapping job executions
- **Timezone support** - Handles different timezones (Kubernetes 1.25+)
- **Suspend capability** - Can pause/resume scheduled executions

## CronJob vs Job

| Feature | Job | CronJob |
|---------|-----|---------|
| **Execution** | One-time | Scheduled/Recurring |
| **Use Cases** | Migrations, Setup | Backups, Reports, Cleanup |
| **Scheduling** | Manual/CI-CD triggered | Time-based (cron syntax) |
| **History** | Single execution | Multiple executions with history |
| **Management** | Simple lifecycle | Schedule management, suspension |

## Files in this Example

```
07-cronjob-backup/
├── hello-cronjob.yaml          # Simple CronJob definition
└── README.md                   # This file
```

## Key CronJob Features

### 1. Simple Schedule Configuration
```yaml
spec:
  schedule: "*/1 * * * *"  # every minute
```

### 2. Basic Job Template
```yaml
jobTemplate:
  spec:
    template:
      spec:
        containers:
        - name: hello
          image: busybox
          command: ["echo", "Hello from Kubernetes CronJob"]
        restartPolicy: OnFailure
```

## Architecture Overview

```
┌─────────────────────────────────────┐
│         CronJob Controller          │
│     Schedule: "*/1 * * * *"         │
│     (Every minute)                  │
└─────────────────┬───────────────────┘
                  │
                  ▼ Creates Jobs every minute
┌─────────────────────────────────────┐
│            Hello Job                │
│  ┌─────────────────────────────────┐│
│  │        Busybox Container        ││
│  │  echo "Hello from Kubernetes    ││
│  │        CronJob"                 ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
                    │  prepare-backup │   mysql-backup    │
                    │  ┌─────────────┐│  ┌─────────────┐  │
                    │  │Check disk   ││  │Full backup  │  │
                    │  │Test DB conn ││  │Schema backup│  │
                    │  │Create dirs  ││  │Data backup  │  │
                    │  └─────────────┘│  │Compress     │  │
                    │                 │  │Cleanup      │  │
                    │                 │  └─────────────┘  │
                    └─────────────────┴───────────────────┘
                                      │
                                      ▼ Stores in
                    ┌─────────────────────────────────────┐
                    │        Persistent Volume            │
                    │    /backup/daily/YYYY/MM/DD/        │
                    │    - Full database backups          │
                    │    - Schema-only backups            │
                    │    - Data-only backups              │
                    │    - Backup manifests               │
                    │    - Cleanup logs                   │
                    └─────────────────────────────────────┘
```

## Key CronJob Features

### 1. Cron Schedule Syntax
```yaml
schedule: "0 2 * * *"  # Every day at 2:00 AM UTC
# Format: minute hour day-of-month month day-of-week
# Examples:
# "*/15 * * * *"      # Every 15 minutes
# "0 */6 * * *"       # Every 6 hours
# "0 2 * * 1"         # Every Monday at 2:00 AM
# "0 0 1 * *"         # First day of every month at midnight
```

### 2. History and Cleanup
```yaml
successfulJobsHistoryLimit: 3  # Keep last 3 successful jobs
failedJobsHistoryLimit: 1      # Keep last 1 failed job
```

### 3. Concurrency Control
```yaml
concurrencyPolicy: Allow       # Allow, Forbid, or Replace
```

## Deployment Instructions

1. **Deploy the CronJob:**
   ```bash
   kubectl apply -f hello-cronjob.yaml
   ```

2. **Verify CronJob creation:**
   ```bash
   kubectl get cronjobs
   kubectl describe cronjob hello-cron
   ```

## Monitoring the CronJob

### Check CronJob Status
```bash
# View CronJob
kubectl get cronjob hello-cron

# Check job history
kubectl get jobs

# Check recent pods
kubectl get pods --sort-by=.metadata.creationTimestamp
```

### View Job Logs
```bash
# Get logs from latest job
kubectl logs -l job-name --tail=50

# Watch for new job executions
kubectl get jobs -w
```

## Cron Schedule Examples

```yaml
# Common cron schedules:
"*/1 * * * *"    # Every minute (for testing)
"*/5 * * * *"    # Every 5 minutes  
"0 */2 * * *"    # Every 2 hours
"0 9 * * *"      # Every day at 9:00 AM
"0 0 * * 0"      # Every Sunday at midnight
"0 0 1 * *"      # First day of every month
```

## Testing and Debugging

### Trigger Manual Execution
```bash
# Create a job from the CronJob template
kubectl create job hello-manual --from=cronjob/hello-cron
```

### Check Job Execution
```bash
# View job details
kubectl describe job [job-name]

# Check pod logs
kubectl logs [pod-name]
```

## Cleanup

```bash
# Delete the CronJob
kubectl delete cronjob hello-cron

# Clean up remaining jobs (optional)
kubectl delete jobs -l cronjob=hello-cron
```

## Important Notes

This is a simple example demonstrating CronJob concepts. In production:

- **Resource limits** should be set appropriately
- **Error handling** should be implemented in scripts
- **Monitoring and alerting** should be configured
- **Proper scheduling** should consider system load
- **Job history limits** should be set to prevent resource buildup

## Production Considerations

For production CronJobs:
- Use **appropriate schedules** to avoid system overload
- Implement **proper error handling** and notifications
- Set **resource limits** and timeouts
- Use **persistent storage** for important outputs
- Configure **monitoring and alerting**
- Plan for **timezone changes** and daylight saving time