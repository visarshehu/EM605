# Nginx Deployment with Multiple Replicas

This example demonstrates a Kubernetes Deployment running multiple nginx replicas serving the default nginx welcome page.

## What is a Deployment?

A Deployment is a Kubernetes resource that:
- Manages ReplicaSets to ensure desired number of pod replicas
- Provides declarative updates for pods and ReplicaSets
- Supports rolling updates and rollbacks
- Offers self-healing capabilities
- Enables easy scaling

## Files in this Example

```
02-deployment-nginx-replicas/
├── nginx-deployment.yaml   # Deployment definition with 3 replicas
└── README.md              # This file
```

## Key Deployment Features

### 1. Replica Management
```yaml
spec:
  replicas: 3  # Desired number of pod replicas
  selector:
    matchLabels:
      app: nginx
```

### 2. Pod Template
```yaml
template:
  metadata:
    labels:
      app: nginx
  spec:
    containers:
    - name: nginx
      image: nginx:latest
      ports:
      - containerPort: 80
```

## Deployment Instructions

### Prerequisites
- Kubernetes cluster running
- kubectl configured

### Deploy the Application

1. **Create the Deployment:**
   ```bash
   kubectl apply -f nginx-deployment.yaml
   ```

2. **Verify deployment:**
   ```bash
   kubectl get deployments
   kubectl get pods -l app=nginx
   kubectl get replicasets
   ```

## Monitoring the Deployment

### Check Deployment Status
```bash
# View deployment details
kubectl get deployments -o wide
kubectl describe deployment nginx-deployment

# Check replica status
kubectl get rs -l app=nginx

# View all pods
kubectl get pods -l app=nginx -o wide
```

### Watch Deployment Progress
```bash
# Watch deployment rollout
kubectl rollout status deployment/nginx-deployment

# Watch pods in real-time
kubectl get pods -l app=nginx --watch
```

## Scaling Operations

### Manual Scaling
```bash
# Scale up to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# Scale down to 2 replicas
kubectl scale deployment nginx-deployment --replicas=2

# Verify scaling
kubectl get pods -l app=nginx
```

### Auto-scaling (HPA)
```bash
# Create horizontal pod autoscaler
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=2 --max=10

# Check HPA status
kubectl get hpa
```

## Rolling Updates

### Update Container Image
```bash
# Update to newer nginx version
kubectl set image deployment/nginx-deployment nginx=nginx:1.22-alpine

# Check rollout status
kubectl rollout status deployment/nginx-deployment

# View rollout history
kubectl rollout history deployment/nginx-deployment
```

### Update via YAML
```bash
# Edit deployment directly
kubectl edit deployment nginx-deployment

# Or apply updated YAML file
kubectl apply -f nginx-deployment.yaml
```

### Rollback Operations
```bash
# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Check rollout history
kubectl rollout history deployment/nginx-deployment
```

## Accessing the Application

### Option 1: Port Forwarding
```bash
kubectl port-forward deployment/nginx-deployment 8080:80
```
Visit: http://localhost:8080

### Option 2: Create a Service (see next example)
```bash
kubectl expose deployment nginx-deployment --type=LoadBalancer --port=80
```

### Option 3: Direct Pod Access
```bash
# Get pod IPs
kubectl get pods -l app=nginx -o wide

# Port forward to specific pod
kubectl port-forward pod/[pod-name] 8080:80
```

## Testing High Availability

### Simulate Pod Failure
```bash
# Delete a pod
kubectl delete pod [pod-name]

# Watch automatic recreation
kubectl get pods -l app=nginx --watch
```

### Drain a Node
```bash
# List nodes
kubectl get nodes

# Drain a node (if using multi-node cluster)
kubectl drain [node-name] --ignore-daemonsets

# Watch pod rescheduling
kubectl get pods -l app=nginx -o wide
```

## Advanced Features

### Resource Requests and Limits
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

### Environment Variables from Pod Metadata
```yaml
env:
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
```

### Pod Disruption Budget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: nginx
```

## Troubleshooting

### Common Issues

1. **Deployment stuck:**
   ```bash
   kubectl describe deployment nginx-deployment
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

2. **Pods not ready:**
   ```bash
   kubectl describe pod [pod-name]
   kubectl logs [pod-name]
   ```

3. **Image pull errors:**
   ```bash
   kubectl describe pod [pod-name]
   # Check image name and registry access
   ```

4. **Resource constraints:**
   ```bash
   kubectl top nodes
   kubectl top pods
   kubectl describe nodes
   ```

### Debugging Commands
```bash
# Check deployment events
kubectl describe deployment nginx-deployment

# Check ReplicaSet events
kubectl describe rs [replicaset-name]

# View pod logs from all replicas
kubectl logs -l app=nginx --all-containers=true

# Execute commands in pods
kubectl exec -it [pod-name] -- /bin/sh
```

## Performance Testing

### Load Testing
```bash
# Install curl pod for testing
kubectl run curl-test --image=curlimages/curl -it --rm -- sh

# Inside the curl pod, test load balancing
for i in {1..10}; do curl -s http://nginx-deployment/info; echo; done
```

### Metrics Collection
```bash
# Check resource usage
kubectl top pods -l app=nginx

# Get detailed pod metrics
kubectl get pods -l app=nginx -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[*].resources.requests.cpu,MEMORY:.spec.containers[*].resources.requests.memory
```

## Cleanup

```bash
# Delete deployment (removes pods and ReplicaSet)
kubectl delete -f nginx-deployment.yaml

# Remove HPA if created
kubectl delete hpa nginx-deployment
```

## Best Practices

1. **Always use resource requests and limits**
2. **Implement proper health checks**
3. **Use appropriate rolling update strategy**
4. **Set pod disruption budgets for critical services**
5. **Monitor deployment status during updates**
6. **Test rollback procedures**
7. **Use meaningful labels and annotations**

## Next Steps

- Learn about **Services** to expose your deployment (next example)
- Explore **Ingress** for advanced routing
- Implement **Monitoring** with Prometheus
- Set up **Logging** with ELK stack
- Configure **Auto-scaling** based on metrics