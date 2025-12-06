# Todo Application with Ingress

This is a todo application that demonstrates a full-stack application deployment on Kubernetes using NGINX Ingress:

- **Frontend**: React application served by Nginx (ClusterIP)
- **Backend**: FastAPI application with REST endpoints (ClusterIP)
- **Database**: MySQL 8.0 with isolated internal access (ClusterIP)
- **Ingress**: NGINX Ingress Controller for unified external access
- **Routing**: Path-based routing with `/` → Frontend, `/api/*` → Backend

## Architecture

```
                    NGINX Ingress Controller
                           │
                           │ (Routes traffic)
                           ▼
┌─────────────────────────────────────────────────────────────┐
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
│                           ┌─────────────────┐              │
│                           │     MySQL       │              │
│                           │   (Database)    │              │
│                           │   ClusterIP     │              │
│                           └─────────────────┘              │
└─────────────────────────────────────────────────────────────┘
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
   
   # Deploy MySQL first
   kubectl apply -f k8s/mysql.yaml
   
   # Wait for MySQL to be ready, then deploy backend
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

## Key Features of Ingress Setup

This version implements **NGINX Ingress** with:

- **Unified Access Point**: Single entry point for all traffic through ingress controller
- **Path-based Routing**: `/` routes to frontend, `/api/*` routes to backend
- **ClusterIP Services**: All services use internal ClusterIP (no NodePort needed)
- **Custom Domain Support**: Access via `todo.local` domain name
- **Enhanced Security**: Only ingress controller is exposed externally
- **Simplified Architecture**: No need to manage multiple ports for different services

## API Endpoints

- `GET /todos` - Get all todos
- `POST /todos` - Create a new todo
- `GET /todos/{id}` - Get a specific todo
- `PUT /todos/{id}` - Update a todo
- `DELETE /todos/{id}` - Delete a todo
- `GET /health` - Health check endpoint

## Database Configuration

**MySQL 8.0 Settings:**
- **Authentication**: `mysql_native_password` (compatible with PyMySQL)
- **User**: `root` with password `password`
- **Database**: `tododb`
- **Connection**: `mysql+pymysql://root:password@mysql-service:3306/tododb`
- **Access**: ClusterIP only (accessed via ingress)

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

# Check pod logs
kubectl logs -l app=todo-frontend
kubectl logs -l app=todo-backend
```

## Namespace Information

This example deploys to the `todo-ingress` namespace for isolation from other examples.

**Useful namespace commands:**
```bash
# View all resources in the namespace
kubectl get all -n todo-ingress

# Delete all resources in the namespace
kubectl delete namespace todo-ingress

# Check ingress in the namespace
kubectl get ingress -n todo-ingress

# Check namespace status
kubectl get namespaces | grep todo
```
