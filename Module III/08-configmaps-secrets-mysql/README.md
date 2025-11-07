# ConfigMaps and Secrets with MySQL

This example demonstrates basic usage of Kubernetes ConfigMaps and Secrets with a MySQL deployment.

## What are ConfigMaps and Secrets?

**ConfigMaps** store non-sensitive configuration data:
- Configuration files
- Environment variables
- Command-line arguments

**Secrets** store sensitive data:
- Passwords
- API keys
- Certificates

## Files in this Example

```
08-configmaps-secrets-mysql/
├── mysql-configmap.yaml         # MySQL configuration file
├── mysql-secret.yaml            # MySQL root password
├── mysql-deployment.yaml        # MySQL deployment using ConfigMap and Secret
└── README.md                    # This file
```

## Key Features

### 1. ConfigMap for MySQL Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    default-authentication-plugin=mysql_native_password
    bind-address=0.0.0.0
    max_connections=100
```

### 2. Secret for Sensitive Data
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  mysql-root-password: MTIzNDU2Nzg5MA==  # "1234567890" base64 encoded
```

### 3. Deployment Using Both
```yaml
env:
- name: MYSQL_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: mysql-secret
      key: mysql-root-password
volumeMounts:
- name: mysql-config
  mountPath: /etc/mysql/conf.d
volumes:
- name: mysql-config
  configMap:
    name: mysql-config
```

## Deployment Instructions

1. **Create the ConfigMap:**
   ```bash
   kubectl apply -f mysql-configmap.yaml
   ```

2. **Create the Secret:**
   ```bash
   kubectl apply -f mysql-secret.yaml
   ```

3. **Deploy MySQL:**
   ```bash
   kubectl apply -f mysql-deployment.yaml
   ```

## Verification

### Check Resources
```bash
# View ConfigMap
kubectl get configmap mysql-config
kubectl describe configmap mysql-config

# View Secret
kubectl get secret mysql-secret
kubectl describe secret mysql-secret

# Check deployment
kubectl get deployment mysql
kubectl get pods -l app=mysql
```

### Test MySQL Connection
```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Connect to MySQL
kubectl exec -it $POD_NAME -- mysql -u root -p1234567890
```

## Base64 Encoding/Decoding

### Create base64 encoded values:
```bash
echo -n "1234567890" | base64
# Output: MTIzNDU2Nzg5MA==
```

### Decode base64 values:
```bash
echo "MTIzNDU2Nzg5MA==" | base64 -d
# Output: 1234567890
```

## Cleanup

```bash
kubectl delete -f mysql-deployment.yaml
kubectl delete -f mysql-secret.yaml
kubectl delete -f mysql-configmap.yaml
```

## Important Notes

This is a basic example demonstrating ConfigMap and Secret usage:
- **Password is simple** - Use strong passwords in production
- **No persistent storage** - Data is lost when pod restarts
- **Basic configuration** - Real deployments need more MySQL configuration
- **Plain Secret** - Consider using external secret management in production

