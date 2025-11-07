# ConfigMaps and Secrets with MySQL

This example demonstrates comprehensive configuration management in Kubernetes using ConfigMaps and Secrets with a MySQL deployment. It showcases different types of configuration data, various mounting methods, and best practices for managing sensitive information.

## What are ConfigMaps and Secrets?

### ConfigMaps
ConfigMaps store **non-sensitive** configuration data in key-value pairs:
- Application settings
- Configuration files
- Environment variables
- Scripts and templates

### Secrets
Secrets store **sensitive** information with base64 encoding:
- Passwords and API keys
- Certificates and private keys
- Database connection strings
- OAuth tokens

## Configuration Types Demonstrated

### 1. Application Configuration (ConfigMap)
- Database connection parameters
- Performance tuning settings
- Feature flags and application settings

### 2. File-based Configuration (ConfigMap)
- MySQL configuration files (.cnf)
- Initialization SQL scripts
- Custom shell scripts

### 3. Sensitive Data (Secrets)
- Database passwords
- SSL/TLS certificates
- External API credentials

### 4. Environment Variables
- Both from ConfigMaps and Secrets
- Using `env`, `envFrom`, and `valueFrom`

## Files in this Example

```
08-configmaps-secrets-mysql/
├── mysql-with-configs.yaml      # StatefulSet with comprehensive configuration
├── mysql-configmaps.yaml        # Various types of ConfigMaps
├── mysql-secrets.yaml          # Different types of Secrets
├── mysql-services-rbac.yaml    # Services, RBAC, and validation job
└── README.md                   # This file
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    MySQL Pod with Configurations                │
├─────────────────────────────────────────────────────────────────┤
│  Init Container    │    MySQL Container    │  Config Manager     │
│  ┌──────────────┐  │  ┌─────────────────┐ │  ┌─────────────────┐│
│  │ Config Init  │  │  │     MySQL       │ │  │ Config Monitor  ││
│  │ - Templates  │  │  │ - Performance   │ │  │ - Watch changes ││
│  │ - Variables  │  │  │ - Security      │ │  │ - Health checks ││
│  │ - Processing │  │  │ - Logging       │ │  │ - Validation    ││
│  └──────────────┘  │  └─────────────────┘ │  └─────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
        ┌───────▼──────┐ ┌──────▼──────┐ ┌─────▼──────┐
        │ ConfigMaps   │ │  Secrets    │ │    PVC     │
        │ - App config │ │ - Passwords │ │ - Data     │
        │ - Templates  │ │ - SSL certs │ │ - Logs     │
        │ - Scripts    │ │ - API keys  │ │            │
        └──────────────┘ └─────────────┘ └────────────┘
```

## Configuration Sources

### 1. Primary Configuration (mysql-config-advanced)
```yaml
data:
  database_name: "config_demo_db"
  max_connections: "200"
  innodb_buffer_pool_size: "512M"
  character_set: "utf8mb4"
```

### 2. Configuration Templates (mysql-config-templates)
```yaml
data:
  performance.cnf: |
    [mysqld]
    max_connections = {{MAX_CONNECTIONS}}
    innodb_buffer_pool_size = {{BUFFER_POOL_SIZE}}
```

### 3. Primary Secrets (mysql-advanced-secret)
```yaml
data:
  root-password: c3VwZXJfc2VjdXJlX3Jvb3RfcGFzc3dvcmRfMjAyNA==
  user-name: YXBwX3VzZXI=
  user-password: YXBwX3NlY3VyZV9wYXNzd29yZF8yMDI0
```

### 4. SSL/TLS Certificates (mysql-ssl-secret)
```yaml
type: kubernetes.io/tls
data:
  ca.pem: |
    LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  server-cert.pem: |
    LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  server-key.pem: |
    LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t...
```

## Deployment Instructions

### Prerequisites
Ensure you have a Kubernetes cluster with:
- Persistent volume support
- RBAC enabled
- Sufficient storage (10Gi+)

### Deploy the Configuration Demo

1. **Create ConfigMaps:**
   ```bash
   kubectl apply -f mysql-configmaps.yaml
   ```

2. **Create Secrets:**
   ```bash
   kubectl apply -f mysql-secrets.yaml
   ```

3. **Create Services and RBAC:**
   ```bash
   kubectl apply -f mysql-services-rbac.yaml
   ```

4. **Deploy MySQL with configurations:**
   ```bash
   kubectl apply -f mysql-with-configs.yaml
   ```

5. **Monitor deployment:**
   ```bash
   kubectl get statefulset mysql-config-demo
   kubectl get pods -l app=mysql-demo
   ```

## Configuration Usage Patterns

### 1. Environment Variables from ConfigMap
```yaml
env:
- name: MYSQL_DATABASE
  valueFrom:
    configMapKeyRef:
      name: mysql-config-advanced
      key: database_name
```

### 2. Environment Variables from Secret
```yaml
env:
- name: MYSQL_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: mysql-advanced-secret
      key: root-password
```

### 3. Bulk Environment Variables
```yaml
envFrom:
- configMapRef:
    name: mysql-env-config
- secretRef:
    name: mysql-optional-secrets
```

### 4. File Mounting from ConfigMap
```yaml
volumeMounts:
- name: config-templates
  mountPath: /config-templates
  readOnly: true
volumes:
- name: config-templates
  configMap:
    name: mysql-config-templates
    defaultMode: 0644
```

### 5. File Mounting from Secret
```yaml
volumeMounts:
- name: ssl-certs
  mountPath: /etc/mysql/ssl
  readOnly: true
volumes:
- name: ssl-certs
  secret:
    secretName: mysql-ssl-secret
    defaultMode: 0600
```

## Testing the Configuration

### Verify MySQL Configuration
```bash
# Check if MySQL is running with correct config
kubectl exec -it mysql-config-demo-0 -- mysql -u root -p"super_secure_root_password_2024" -e "SHOW VARIABLES LIKE 'max_connections';"

# Check character set configuration
kubectl exec -it mysql-config-demo-0 -- mysql -u root -p"super_secure_root_password_2024" -e "SHOW VARIABLES LIKE 'character_set%';"

# Verify database creation
kubectl exec -it mysql-config-demo-0 -- mysql -u root -p"super_secure_root_password_2024" -e "SHOW DATABASES;"
```

### Test Application User
```bash
# Connect as application user
kubectl exec -it mysql-config-demo-0 -- mysql -u app_user -p"app_secure_password_2024" config_demo_db -e "SELECT * FROM config_settings LIMIT 5;"
```

### Run Configuration Validation
```bash
# Run the validation job
kubectl apply -f mysql-services-rbac.yaml

# Check validation results
kubectl logs job/mysql-config-validation
```

## Configuration Management Operations

### View ConfigMaps
```bash
# List all ConfigMaps
kubectl get configmaps -l app=mysql-demo

# View specific ConfigMap content
kubectl get configmap mysql-config-advanced -o yaml

# View configuration templates
kubectl get configmap mysql-config-templates -o jsonpath='{.data.performance\.cnf}'
```

### View Secrets
```bash
# List secrets (values are hidden)
kubectl get secrets -l app=mysql-demo

# View secret keys (not values)
kubectl describe secret mysql-advanced-secret

# Decode secret value (be careful with this!)
kubectl get secret mysql-advanced-secret -o jsonpath='{.data.root-password}' | base64 -d
```

### Update Configuration
```bash
# Update ConfigMap
kubectl patch configmap mysql-config-advanced --patch '{"data":{"max_connections":"300"}}'

# Update Secret (base64 encode new value first)
NEW_PASSWORD=$(echo -n "new_secure_password" | base64)
kubectl patch secret mysql-advanced-secret --patch '{"data":{"root-password":"'$NEW_PASSWORD'"}}'

# Restart StatefulSet to pick up changes
kubectl rollout restart statefulset/mysql-config-demo
```

## Configuration File Management

### Check Generated Configuration
```bash
# View the dynamically generated MySQL configuration
kubectl exec mysql-config-demo-0 -- cat /etc/mysql/conf.d/99-dynamic.cnf

# Check all configuration files
kubectl exec mysql-config-demo-0 -- ls -la /etc/mysql/conf.d/

# View specific configuration file
kubectl exec mysql-config-demo-0 -- cat /etc/mysql/conf.d/performance.cnf
```

### Monitor Configuration Changes
```bash
# Check config manager logs
kubectl logs mysql-config-demo-0 -c config-manager -f

# View configuration processing logs
kubectl logs mysql-config-demo-0 -c config-init
```

## Advanced Configuration Patterns

### Configuration Inheritance
```yaml
# Base configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-base-config
data:
  charset: "utf8mb4"
  
---
# Environment-specific override
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-prod-config
data:
  max_connections: "500"
  buffer_size: "2G"
```

### Template Processing with Init Containers
```yaml
initContainers:
- name: config-processor
  image: alpine:3.18
  command:
  - /bin/sh
  - -c
  - |
    # Process configuration templates
    envsubst < /templates/mysql.cnf.template > /config/mysql.cnf
```

### Dynamic Configuration Reloading
```yaml
- name: config-reloader
  image: alpine:3.18
  command:
  - /bin/sh
  - -c
  - |
    inotifywait -m /config -e modify |
    while read path action file; do
      echo "Config changed: $file"
      # Signal MySQL to reload configuration
      mysqladmin -h localhost flush-privileges
    done
```

## Security Best Practices

### Secret Management
```bash
# Create secret from command line (more secure)
kubectl create secret generic mysql-secret \
  --from-literal=password="secure_password" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create secret from file
echo -n "secure_password" > ./password.txt
kubectl create secret generic mysql-secret \
  --from-file=password=./password.txt
rm ./password.txt
```

### RBAC for Configuration Access
```yaml
# Limit access to specific secrets
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["mysql-advanced-secret"]
  verbs: ["get"]
```

### Secret Rotation
```bash
# Script for secret rotation
#!/bin/bash
NEW_PASSWORD=$(openssl rand -base64 32)
kubectl patch secret mysql-advanced-secret \
  --patch '{"data":{"root-password":"'$(echo -n $NEW_PASSWORD | base64)'"}}}'
kubectl rollout restart statefulset/mysql-config-demo
```

## Monitoring and Observability

### Configuration Drift Detection
```yaml
- name: config-monitor
  image: alpine:3.18
  command:
  - /bin/sh
  - -c
  - |
    while true; do
      # Check if running config matches desired config
      CURRENT_MAX_CONN=$(mysql -sNe "SELECT @@max_connections;")
      DESIRED_MAX_CONN=$MYSQL_MAX_CONNECTIONS
      
      if [ "$CURRENT_MAX_CONN" != "$DESIRED_MAX_CONN" ]; then
        echo "Configuration drift detected!"
        echo "Current: $CURRENT_MAX_CONN, Desired: $DESIRED_MAX_CONN"
      fi
      sleep 300
    done
```

### Configuration Validation
```bash
# Validate configuration before applying
kubectl apply --dry-run=server -f mysql-configmaps.yaml

# Test configuration syntax
kubectl exec mysql-config-demo-0 -- mysqld --help --verbose > /dev/null
```

## Troubleshooting

### Common Issues

1. **Secret not found:**
   ```bash
   kubectl describe pod mysql-config-demo-0
   # Check events for secret mounting issues
   ```

2. **ConfigMap not mounted:**
   ```bash
   kubectl exec mysql-config-demo-0 -- ls -la /etc/mysql/conf.d/
   # Verify files are present
   ```

3. **Permission denied on secret files:**
   ```bash
   kubectl exec mysql-config-demo-0 -- ls -la /etc/mysql/ssl/
   # Check file permissions (should be 0600 for secrets)
   ```

4. **Configuration not applied:**
   ```bash
   # Check MySQL configuration loading
   kubectl exec mysql-config-demo-0 -- mysql -e "SHOW VARIABLES LIKE 'max_connections';"
   ```

### Debug Commands
```bash
# Check all mounted volumes
kubectl exec mysql-config-demo-0 -- mount | grep mysql

# View environment variables
kubectl exec mysql-config-demo-0 -- env | grep MYSQL

# Check configuration file syntax
kubectl exec mysql-config-demo-0 -- mysqld --help --verbose

# View MySQL error log
kubectl exec mysql-config-demo-0 -- tail -f /var/lib/mysql/error.log
```

## Configuration Backup and Recovery

### Backup Configuration
```bash
# Export all ConfigMaps
kubectl get configmaps -l app=mysql-demo -o yaml > mysql-configmaps-backup.yaml

# Export all Secrets (excluding sensitive data)
kubectl get secrets -l app=mysql-demo -o yaml | \
  sed 's/data:/stringData:/' | \
  sed 's/: [A-Za-z0-9+\/=]*$/: <REDACTED>/' > mysql-secrets-backup.yaml
```

### Configuration Version Control
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config-advanced
  annotations:
    config.version: "1.2.0"
    config.changelog: "Increased max_connections from 200 to 300"
data:
  # ... configuration data
```

## Cleanup

```bash
# Delete StatefulSet
kubectl delete statefulset mysql-config-demo

# Delete services
kubectl delete service mysql-config-demo mysql-config-demo-headless

# Delete validation job
kubectl delete job mysql-config-validation

# Delete ConfigMaps and Secrets
kubectl delete -f mysql-configmaps.yaml
kubectl delete -f mysql-secrets.yaml

# Delete RBAC
kubectl delete -f mysql-services-rbac.yaml

# Delete PVCs (WARNING: This deletes data!)
kubectl delete pvc -l app=mysql-demo
```

## Best Practices Summary

### ConfigMaps
1. **Use for non-sensitive data only**
2. **Organize by function** (app config, templates, scripts)
3. **Use meaningful names and labels**
4. **Include documentation in annotations**
5. **Version your configurations**

### Secrets
1. **Never store secrets in version control**
2. **Use appropriate secret types** (Opaque, TLS, etc.)
3. **Implement secret rotation**
4. **Limit access with RBAC**
5. **Monitor secret access**

### General
1. **Separate configuration by environment**
2. **Use init containers for complex processing**
3. **Implement configuration validation**
4. **Monitor configuration drift**
5. **Plan for configuration rollbacks**
6. **Use external secret management** (Vault, etc.) for production

This example demonstrates enterprise-grade configuration management patterns that can be adapted for any application requiring complex configuration handling in Kubernetes.