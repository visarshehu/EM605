# Simple DaemonSet Example

This example demonstrates a basic Kubernetes DaemonSet that runs a simple logging container on every node in the cluster.

## What is a DaemonSet?

A DaemonSet ensures that a copy of a Pod runs on all (or selected) nodes in a cluster. Key characteristics:
- **One pod per node** - Automatically schedules on new nodes
- **Node-level services** - Perfect for infrastructure components
- **Automatic cleanup** - Removes pods when nodes are removed
- **Tolerations** - Can run on nodes with taints (including master nodes)

## Use Cases for DaemonSets

- **Log collection** - Fluentd, Filebeat, Logstash
- **Monitoring agents** - Node Exporter, cAdvisor, Datadog agent  
- **Network proxies** - Kube-proxy, CNI plugins
- **Security agents** - Falco, Twistlock
- **Storage daemons** - Ceph, GlusterFS

## Files in this Example

```
05-daemonset-logging/
├── node-logger-daemonset.yaml     # Simple DaemonSet with busybox
└── README.md                      # This file
```

## Architecture Overview

```
┌───────────────────────────────────────────────────────┐
│                 Kubernetes Cluster                   │
├─────────────┬─────────────┬─────────────┬─────────────┤
│   Node 1    │   Node 2    │   Node 3    │   Node 4    │
│ ┌─────────┐ │ ┌─────────┐ │ ┌─────────┐ │ ┌─────────┐ │
│ │node-    │ │ │node-    │ │ │node-    │ │ │node-    │ │
│ │logger   │ │ │logger   │ │ │logger   │ │ │logger   │ │
│ │(busybox)│ │ │(busybox)│ │ │(busybox)│ │ │(busybox)│ │
│ └─────────┘ │ └─────────┘ │ └─────────┘ │ └─────────┘ │
└─────────────┴─────────────┴─────────────┴─────────────┘
## Key DaemonSet Features

### 1. Simple Container Definition
```yaml
containers:
- name: logger
  image: busybox
  command: ["/bin/sh", "-c", "while true; do echo Node $(hostname) active; sleep 10; done"]
```

### 2. Automatic Node Scheduling
- DaemonSet automatically creates one pod per node
- New nodes get pods automatically
- Pods are removed when nodes are removed

## Deployment Instructions

### Prerequisites
- Kubernetes cluster (minikube or multi-node)
- kubectl configured

### Deploy the Node Logger DaemonSet

1. **Deploy the DaemonSet:**
   ```bash
   kubectl apply -f node-logger-daemonset.yaml
   ```

2. **Verify deployment:**
   ```bash
   kubectl get daemonset node-logger
   kubectl get pods -l app=node-logger -o wide
   ```

## Monitoring DaemonSet

### Check DaemonSet Status
```bash
# View DaemonSet
kubectl get daemonset node-logger -o wide

# Check pods on each node
kubectl get pods -l app=node-logger -o wide

# View DaemonSet details
kubectl describe daemonset node-logger
```

### Node Coverage Verification
```bash
# Verify pod is running on each node
kubectl get nodes
kubectl get pods -l app=node-logger -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName

# Check for scheduling issues
kubectl get events --field-selector reason=FailedScheduling
```

## Testing the DaemonSet

### View Pod Logs
```bash
# Check logs from all node-logger pods
kubectl logs -l app=node-logger -f

# View logs from a specific pod
POD_NAME=$(kubectl get pods -l app=node-logger -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME -f
```

### Verify Node Coverage
```bash
# Count total nodes and pods
echo "Nodes: $(kubectl get nodes --no-headers | wc -l)"
echo "DaemonSet pods: $(kubectl get pods -l app=node-logger --no-headers | wc -l)"

# Should be equal numbers
```

## Cleanup

```bash
# Delete the DaemonSet
kubectl delete daemonset node-logger

# Verify cleanup
kubectl get pods -l app=node-logger
```

## Important Notes

This is a simplified example demonstrating DaemonSet concepts. In production:

- **Resource limits** should be set appropriately
- **Security contexts** should be configured
- **Monitoring and health checks** should be implemented
- **Log rotation and storage** should be managed
- **Real logging solutions** like Fluentd, Filebeat, or Logstash would be used

## Next Steps

This example shows the basic DaemonSet pattern. For production logging:
- Use **Fluentd** or **Filebeat** for real log collection
- Implement **centralized logging** with ELK or Loki stack
- Add **log parsing and filtering**
- Set up **log retention policies**
- Configure **monitoring and alerting**