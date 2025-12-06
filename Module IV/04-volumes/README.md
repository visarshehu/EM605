# Todo Application with Persistent Volumes

This is a todo application that demonstrates a full-stack application deployment on Kubernetes using StatefulSets and persistent volumes:

- **Frontend**: React application served by Nginx (ClusterIP)
- **Backend**: FastAPI application with REST endpoints (ClusterIP)
- **Database**: MySQL 8.0 StatefulSet with persistent storage
- **Storage**: Persistent Volume Claims for data persistence (1Gi)
- **Ingress**: NGINX Ingress Controller for unified external access
- **Routing**: Path-based routing with `/` → Frontend, `/api/*` → Backend

## Architecture

```
                    NGINX Ingress Controller
                           │
                           │ (Routes traffic)
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                     todo.local                              │
│  /          │                    /api/*                    │
│      ▼      │                       ▼                      │
│┌─────────────────┐         ┌─────────────────┐             │
││   Frontend      │         │   Backend       │             │
││ (React/Nginx)   │────────▶│   (FastAPI)     │─────────────┤
││ ClusterIP:80    │         │ ClusterIP:8000  │             │
│└─────────────────┘         └─────────────────┘             │
│                                     │                      │
│                                     ▼                      │
│                    ┌─────────────────────────────┐         │
│                    │    MySQL StatefulSet        │         │
│                    │   (Persistent Database)     │         │
│                    │                             │         │
│                    │  ┌─────────────────────┐    │         │
│                    │  │ Persistent Volume   │    │         │
│                    │  │    (1Gi Storage)    │    │         │
│                    │  └─────────────────────┘    │         │
│                    └─────────────────────────────┘         │
│                      Headless + Regular Service            │
└──────────────────────────────────────────────────────────────┘
```

## Quick Start

1. **Build the Docker images:**
   ```bash
   # Build backend image
   cd todo-backend
   docker build -t todo-backend:latest .
   cd ..
   
   # Build frontend image
   cd todo-frontend
   docker build -t todo-frontend:latest .
   cd ..
   ```

2. **Enable NGINX Ingress in Minikube:**
   ```bash
   # Enable the ingress addon
   minikube addons enable ingress
   
   # Verify ingress controller is running
   kubectl get pods -n ingress-nginx
   ```

3. **Load images into Minikube:**
   ```bash
   # Since Minikube uses its own Docker environment, load the locally built images
   minikube image load todo-backend:latest
   minikube image load todo-frontend:latest
   
   # Verify images are loaded (optional)
   minikube image ls | grep todo
   ```

4. **Deploy to Kubernetes:**
   ```bash
   # Create the namespace first
   kubectl apply -f k8s/namespace.yaml
   
   # Deploy MySQL StatefulSet with persistent volumes first
   kubectl apply -f k8s/mysql.yaml
   
   # Check that the PVC is bound (may take a moment)
   kubectl get pvc -n todo-volumes
   
   # Wait for MySQL StatefulSet to be ready, then deploy backend
   kubectl apply -f k8s/todo-backend.yaml
   
   # Deploy frontend
   kubectl apply -f k8s/todo-frontend.yaml
   
   # Deploy ingress
   kubectl apply -f k8s/ingress.yaml
   ```

5. **Access the application:**

   **Option A: Using Custom Domain (Recommended)**
   ```bash
   # Add todo.local to your /etc/hosts file
   echo "$(minikube ip) todo.local" | sudo tee -a /etc/hosts
   
   # Access the application
   open http://todo.local
   ```
   
   **Option B: Using Minikube IP directly**
   ```bash
   # Get Minikube IP and access via IP
   minikube ip
   # Then visit: http://<MINIKUBE_IP>
   ```
   
   **Ingress Access:**
   - **Application**: `http://todo.local` or `http://<MINIKUBE_IP>`
   - **API Endpoints**: `http://todo.local/api/todos` or `http://<MINIKUBE_IP>/api/todos`
   - **API Documentation**: `http://todo.local/api/docs` or `http://<MINIKUBE_IP>/api/docs`
   - **MySQL Database**: **NOT ACCESSIBLE** from outside (ClusterIP only)
   
   **Note**: All traffic is routed through the NGINX Ingress Controller. The frontend serves at `/` and API calls are routed to `/api/*`.

## Key Features of Persistent Volume Setup

This version implements **StatefulSets with Persistent Volumes**:

- **Data Persistence**: MySQL data survives pod restarts and rescheduling
- **StatefulSet**: Ordered deployment and scaling for stateful applications
- **Headless Service**: Direct pod-to-pod communication for StatefulSet
- **Volume Claims**: Automatic persistent volume provisioning (1Gi storage)
- **Health Checks**: Proper MySQL liveness and readiness probes
- **NGINX Ingress**: Unified access point for all traffic
- **Path-based Routing**: `/` routes to frontend, `/api/*` routes to backend
- **Enhanced Reliability**: Database state is preserved across cluster changes

## API Endpoints

- `GET /todos` - Get all todos
- `POST /todos` - Create a new todo
- `GET /todos/{id}` - Get a specific todo
- `PUT /todos/{id}` - Update a todo
- `DELETE /todos/{id}` - Delete a todo
- `GET /health` - Health check endpoint

## Database Configuration

**MySQL 8.0 StatefulSet Settings:**
- **Authentication**: `mysql_native_password` (compatible with PyMySQL)
- **User**: `root` with password `password`
- **Database**: `tododb`
- **Connection**: `mysql+pymysql://root:password@mysql-service:3306/tododb`
- **Storage**: 1Gi persistent volume (data survives pod restarts)
- **Access**: ClusterIP + Headless service for StatefulSet

**Note**: If upgrading an existing StatefulSet, the root user authentication may need to be updated manually:
```sql
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
```

## Database Schema

```sql
CREATE TABLE todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    completed BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## Development

### Backend Development
```bash
cd todo-backend
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Frontend Development
```bash
cd todo-frontend
npm install
npm start
```

## Troubleshooting

### Ingress Not Working
```bash
# Check if ingress addon is enabled
minikube addons list | grep ingress

# Check ingress controller pods
kubectl get pods -n ingress-nginx

# Check ingress resources
kubectl get ingress

# Check ingress details
kubectl describe ingress todo-app-ingress
```

### Services Not Accessible
```bash
# Check all services
kubectl get services

# Check if pods are running
kubectl get pods

# Check StatefulSet status
kubectl get statefulsets

# Check persistent volume claims
kubectl get pvc

# Check pod logs
kubectl logs -l app=todo-frontend
kubectl logs -l app=todo-backend
kubectl logs -l app=mysql
```

### Persistent Volume Issues
```bash
# Check PVC status
kubectl get pvc -n todo-volumes
kubectl describe pvc mysql-data-mysql-statefulset-0 -n todo-volumes

# Check if storage class exists
kubectl get storageclass

# For minikube, ensure you have enough disk space
minikube ssh "df -h"
```

### StatefulSet Database Authentication Issues
For persistent StatefulSets, the user authentication method may need manual update:

```bash
# Check current authentication method
kubectl exec -n todo-volumes mysql-statefulset-0 -- mysql -u root -ppassword -e "SELECT User, Host, plugin FROM mysql.user WHERE User='root';"

# If users still use caching_sha2_password, update them:
kubectl exec -n todo-volumes mysql-statefulset-0 -- mysql -u root -ppassword -e "
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
"
```

## Namespace Information

This example deploys to the `todo-volumes` namespace for isolation from other examples.

**Useful namespace commands:**
```bash
# View all resources in the namespace
kubectl get all -n todo-volumes

# Check persistent volumes and claims
kubectl get pv,pvc -n todo-volumes

# Check StatefulSet status
kubectl get statefulset -n todo-volumes

# Delete all resources in the namespace
kubectl delete namespace todo-volumes

# Check namespace status
kubectl get namespaces | grep todo
```

## Features

- ✅ Create new todos with title and description
- ✅ Mark todos as completed/uncompleted
- ✅ Delete todos
- ✅ **Persistent MySQL storage** with StatefulSet
- ✅ **Data survives** pod restarts and cluster changes
- ✅ **Automatic volume provisioning** (1Gi persistent volumes)
- ✅ **Headless service** for StatefulSet pod discovery
- ✅ NGINX Ingress Controller for unified access
- ✅ Path-based routing (/ → frontend, /api/* → backend)
- ✅ Custom domain support (todo.local)
- ✅ All services isolated with ClusterIP
- ✅ Responsive web interface
- ✅ Enhanced MySQL health checks (liveness & readiness probes)
- ✅ Horizontal scaling (2 replicas each for frontend and backend)
- ✅ Production-ready database persistence