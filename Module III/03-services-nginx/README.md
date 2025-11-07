# Kubernetes Services for Nginx Deployment

This example demonstrates different types of Kubernetes Services and how they provide network access to a deployment with multiple nginx replicas serving the default nginx welcome page.

## What are Kubernetes Services?

A Service is an abstract way to expose an application running on a set of Pods. Services provide:
- **Stable networking** - Fixed IP address and DNS name
- **Load balancing** - Traffic distribution across pods
- **Service discovery** - DNS-based discovery mechanism
- **Decoupling** - Applications don't need to know about individual pods

## Service Types Demonstrated

### 1. ClusterIP (Default)
- **Purpose**: Internal cluster communication
- **Access**: Only from within the cluster
- **Use case**: Backend services, databases

### 2. NodePort
- **Purpose**: External access via node IPs
- **Access**: `<NodeIP>:<NodePort>`
- **Use case**: Development, testing, simple external access

### 3. LoadBalancer
- **Purpose**: External load balancer (cloud providers)
- **Access**: External IP provided by cloud
- **Use case**: Production external services

### 4. Headless
- **Purpose**: Direct pod access without load balancing
- **Access**: Returns individual pod IPs via DNS
- **Use case**: StatefulSets, direct pod communication

### 5. ExternalName
- **Purpose**: Maps service to external DNS name
- **Access**: CNAME record mapping
- **Use case**: External service integration

## Files in this Example

```
03-services-nginx/
├── nginx-deployment.yaml   # Deployment with 3 replicas
├── services.yaml          # All service types
└── README.md             # This file
```

## Deployment Instructions

### Prerequisites
- Kubernetes cluster running
- kubectl configured

### Deploy Everything

1. **Deploy the application:**
   ```bash
   kubectl apply -f nginx-deployment.yaml
   ```

2. **Create services:**
   ```bash
   kubectl apply -f services.yaml
   ```

4. **Verify deployment:**
   ```bash
   kubectl get deployments,services,pods
   ```

## Accessing Different Service Types

### ClusterIP Service
```bash
# Only accessible from within cluster
kubectl run test-pod --image=curlimages/curl -it --rm -- sh
# Inside the pod:
curl nginx-clusterip

# Or use port-forwarding from outside:
kubectl port-forward service/nginx-clusterip 8080:80
# Access: http://localhost:8080
```

### NodePort Service
```bash
# Get node IPs
kubectl get nodes -o wide

# Access via any node IP (if using minikube):
minikube ip
# Access: http://<minikube-ip>:30080

# Or port-forward:
kubectl port-forward service/nginx-nodeport 8080:80
```

### LoadBalancer Service
```bash
# Check external IP (may be pending in local clusters)
kubectl get service nginx-loadbalancer

# Port-forward for testing:
kubectl port-forward service/nginx-loadbalancer 8080:80
```

### Headless Service
```bash
# Test DNS resolution (returns all pod IPs)
kubectl run dns-test --image=busybox -it --rm -- nslookup nginx-headless.default.svc.cluster.local

# Direct pod access via service
kubectl port-forward service/nginx-headless 8080:80
```

## Service Discovery and DNS

### Built-in DNS Names

Services are automatically assigned DNS names:

```bash
# Full FQDN format
<service-name>.<namespace>.svc.cluster.local

# Examples
nginx-clusterip.default.svc.cluster.local
nginx-nodeport.default.svc.cluster.local
nginx-loadbalancer.default.svc.cluster.local
```

### Test Service Discovery
```bash
# From within cluster
kubectl run dns-test --image=busybox -it --rm -- sh

# Inside the pod:
nslookup nginx-clusterip
nslookup nginx-clusterip.default
nslookup nginx-clusterip.default.svc.cluster.local

# Test connectivity
wget -qO- nginx-clusterip
```

## Load Balancing Demonstration

### Test Load Distribution
```bash
# Run multiple requests to see different pods respond
kubectl run curl-test --image=curlimages/curl -it --rm -- sh

# Inside the pod, run multiple requests:
for i in {1..10}; do
  curl -s nginx-clusterip/api/info | grep pod
done
```

### Expected Output
You should see responses from different pods, demonstrating load balancing:
```json
{"pod":"nginx-web-app-abc123","ip":"10.1.1.1",...}
{"pod":"nginx-web-app-def456","ip":"10.1.1.2",...}
{"pod":"nginx-web-app-ghi789","ip":"10.1.1.3",...}
```

## Advanced Service Features

### Session Affinity
```yaml
# Sticky sessions
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

### Service with Multiple Ports
```yaml
ports:
- name: http
  port: 80
  targetPort: 80
- name: https
  port: 443
  targetPort: 443
```

### Health Checks Integration
```yaml
# Services automatically exclude unhealthy pods
readinessProbe:
  httpGet:
    path: /ready
    port: 80
```

## Monitoring Services

### Service Status
```bash
# View all services
kubectl get services -o wide

# Describe specific service
kubectl describe service nginx-clusterip

# Check endpoints (actual pod IPs)
kubectl get endpoints nginx-clusterip
```

### Service Logs and Debugging
```bash
# Check pod logs behind service
kubectl logs -l app=nginx-web --all-containers=true

# Test connectivity from another pod
kubectl run debug --image=nicolaka/netshoot -it --rm -- sh
# Inside the pod:
curl -v nginx-clusterip
dig nginx-clusterip.default.svc.cluster.local
```

## Service Mesh Integration

### With Istio
```yaml
# Service mesh sidecar injection
metadata:
  annotations:
    sidecar.istio.io/inject: "true"
```

### With Linkerd
```yaml
# Linkerd annotation
metadata:
  annotations:
    linkerd.io/inject: enabled
```

## Troubleshooting

### Common Issues

1. **Service not accessible:**
   ```bash
   # Check service endpoints
   kubectl get endpoints <service-name>
   
   # Check pod labels match service selector
   kubectl get pods --show-labels
   kubectl describe service <service-name>
   ```

2. **LoadBalancer pending:**
   ```bash
   # Check if cloud provider supports LoadBalancer
   kubectl describe service nginx-loadbalancer
   
   # Use MetalLB for bare-metal clusters
   ```

3. **DNS resolution fails:**
   ```bash
   # Check CoreDNS
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   
   # Test DNS from pod
   kubectl exec -it <pod-name> -- nslookup kubernetes.default
   ```

4. **NodePort not accessible:**
   ```bash
   # Check node firewall rules
   # Verify nodePort is in valid range (30000-32767)
   kubectl get service <service-name> -o yaml
   ```

## Performance Testing

### Load Testing with hey
```bash
# Install hey in a pod
kubectl run hey --image=rcmorano/hey -it --rm -- sh

# Inside the pod:
hey -n 1000 -c 10 -z 30s http://nginx-clusterip/
```

### Monitor Resource Usage
```bash
# Check pod resource usage
kubectl top pods -l app=nginx-web

# Check service endpoints distribution
kubectl get endpoints nginx-clusterip -o yaml
```

## Security Considerations

### Network Policies
```yaml
# Restrict access to service
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-netpol
spec:
  podSelector:
    matchLabels:
      app: nginx-web
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
```

### Service Account
```yaml
# Custom service account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-service-account
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f .

# Or delete individually
kubectl delete deployment nginx-web-app
kubectl delete service nginx-clusterip nginx-nodeport nginx-loadbalancer nginx-headless nginx-external-alias
```

## Best Practices

1. **Use ClusterIP for internal services**
2. **Use LoadBalancer for production external access**
3. **Implement proper health checks**
4. **Use meaningful service names**
5. **Configure appropriate session affinity**
6. **Monitor service endpoints regularly**
7. **Use network policies for security**
8. **Test service discovery thoroughly**

## Next Steps

- Explore **Ingress** for HTTP/HTTPS routing
- Implement **Service Mesh** for advanced traffic management
- Set up **External DNS** for automatic DNS management
- Configure **Certificate management** with cert-manager
- Learn about **Multi-cluster services**