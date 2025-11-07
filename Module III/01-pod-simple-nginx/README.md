# Simple Nginx Pod

This example demonstrates a basic Kubernetes Pod running a single nginx container serving the default nginx welcome page.

## What is a Pod?

A Pod is the smallest deployable unit in Kubernetes that can contain one or more containers. Containers in a Pod:
- Share the same network (IP address and ports)
- Share storage volumes
- Are scheduled together on the same node
- Live and die together

## Files in this Example

```
01-pod-simple-nginx/
├── nginx-pod.yaml       # Pod definition
└── README.md           # This file
```

## Key Pod Features Demonstrated

### 1. Container Configuration
```yaml
containers:
- name: nginx
  image: nginx:latest
  ports:
  - containerPort: 80
```

## Deployment Instructions

### Prerequisites
- Kubernetes cluster running (minikube, kind, or cloud cluster)
- kubectl configured to connect to your cluster

### Deploy the Pod

1. **Create the Pod:**
   ```bash
   kubectl apply -f nginx-pod.yaml
   ```

2. **Verify deployment:**
   ```bash
   kubectl get pods
   kubectl get pods -o wide  # Shows node assignment
   ```

### Access the Pod

#### Option 1: Port Forwarding
```bash
kubectl port-forward pod/nginx-simple 8080:80
```
Then visit: http://localhost:8080

#### Option 2: Temporary Service
```bash
kubectl expose pod nginx-simple --type=NodePort --port=80
kubectl get services
```

#### Option 3: Direct Pod Access (if using minikube)
```bash
minikube ip  # Get cluster IP
kubectl get pod nginx-simple -o wide  # Get node
# Access via NodeIP:Port
```

## Monitoring and Debugging

### Check Pod Status
```bash
# Basic status
kubectl get pods

# Detailed information
kubectl describe pod nginx-simple

# Pod events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### View Logs
```bash
# Current logs
kubectl logs nginx-simple

# Follow logs
kubectl logs -f nginx-simple

# Previous container logs (if restarted)
kubectl logs nginx-simple --previous
```

### Execute Commands in Pod
```bash
# Get shell access
kubectl exec -it nginx-simple -- /bin/sh

# Run specific commands
kubectl exec nginx-simple -- nginx -t
kubectl exec nginx-simple -- ps aux
```

### Test HTTP Access
```bash
# Test basic connectivity
kubectl exec nginx-simple -- curl -f http://localhost/
```

## Pod Lifecycle

### Pod States
- **Pending**: Pod accepted but not yet scheduled
- **Running**: Pod bound to node and all containers created
- **Succeeded**: All containers terminated successfully
- **Failed**: All containers terminated, at least one failed
- **Unknown**: Pod state cannot be determined

### Pod Restart Policy
```yaml
restartPolicy: Always  # Always restart containers
# Options: Always, OnFailure, Never
```

## Troubleshooting

### Common Issues

1. **Pod stuck in Pending:**
   ```bash
   kubectl describe pod nginx-simple
   # Check events for scheduling issues
   ```

2. **Pod crash looping:**
   ```bash
   kubectl logs nginx-simple --previous
   # Check previous container logs
   ```

3. **Resource constraints:**
   ```bash
   kubectl top nodes
   kubectl top pods
   # Check resource usage
   ```

## Cleanup

```bash
# Delete the pod
kubectl delete -f nginx-pod.yaml
```

## Next Steps

This example demonstrates a single Pod. In production, you typically use:
- **Deployments** for stateless applications (see next example)
- **StatefulSets** for stateful applications
- **DaemonSets** for node-level services
- **Jobs** for batch processing

Pods are usually managed by higher-level controllers rather than created directly.