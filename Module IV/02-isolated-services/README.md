# Todo Application with Isolated Services

This is a todo application that demonstrates a full-stack application deployment on Kubernetes with isolated services:

- **Frontend**: React application served by Nginx (ClusterIP)
- **Backend**: FastAPI application with REST endpoints (ClusterIP)  
- **Database**: MySQL 8.0 with isolated internal access (ClusterIP service only)
- **Deployment**: Kubernetes manifests with selective external access

## Architecture

```
External Access                 Internal Cluster Communication
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Todo Frontend │    │   Todo Backend  │    │     MySQL       │
│   (React/Nginx) │───▶│    (FastAPI)    │───▶│   (Database)    │
│   Port: 30000   │    │   Port: 30001   │    │   ClusterIP     │
│   (NodePort)    │    │   (NodePort)    │    │   (Isolated)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
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

2. **Load images into Minikube:**
   ```bash
   # Since Minikube uses its own Docker environment, load the locally built images
   minikube image load todo-backend:latest
   minikube image load todo-frontend:latest
   
   # Verify images are loaded (optional)
   minikube image ls | grep todo
   ```

3. **Deploy to Kubernetes:**
   ```bash
   # Create the namespace first
   kubectl apply -f k8s/namespace.yaml
   
   # Deploy MySQL first
   kubectl apply -f k8s/mysql.yaml
   
   # Wait for MySQL to be ready, then deploy backend
   kubectl apply -f k8s/todo-backend.yaml
   
   # Deploy frontend
   kubectl apply -f k8s/todo-frontend.yaml
   ```

4. **Access the application:**
   
   The application uses internal Kubernetes service communication with Nginx proxy for API calls.
   
   **Option A: Using Minikube Service (Recommended)**
   ```bash
   # Start the frontend service (this opens the app in your browser)
   minikube service todo-frontend-service -n todo-isolated
   ```
   
   **Option B: Using Minikube IP directly**
   ```bash
   # Get Minikube IP and access the frontend
   minikube ip
   # Then visit: http://<MINIKUBE_IP>:30000
   ```
   
   **Direct Service Access:**
   - Frontend: Access via minikube service or `<MINIKUBE_IP>:30000`
   - Backend API (direct): `<MINIKUBE_IP>:30001`
   - MySQL Database: **NOT ACCESSIBLE** from outside the cluster (ClusterIP only)
   - API Documentation: `<MINIKUBE_IP>:30001/docs`
   
   **Note**: The frontend automatically proxies API calls to `/api/*` to the backend service internally.

## Key Differences from Simple Todo App

This version implements **service isolation** by:

- **MySQL Service**: Changed from `NodePort` to `ClusterIP` type, making the database accessible only within the Kubernetes cluster
- **Enhanced Security**: Database is no longer exposed to external traffic, reducing the attack surface
- **Internal Communication**: Backend connects to MySQL using the internal service name (`mysql-service:3306`)
- **Selective Exposure**: Only frontend and backend APIs are accessible externally, database remains isolated

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
- **Access**: ClusterIP only (not accessible externally)

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

## Troubleshooting

### Database Authentication Issues
If you encounter Internal Server Error or authentication issues:

1. **Check MySQL authentication method**:
   ```bash
   kubectl exec -n todo-isolated deployment/mysql-deployment -- mysql -u root -ppassword -e "SELECT @@default_authentication_plugin;"
   ```

2. **Test database connection from backend**:
   ```bash
   kubectl exec -n todo-isolated deployment/todo-backend-deployment -- python -c "
   from sqlalchemy import create_engine, text
   import os
   try:
       engine = create_engine(os.getenv('DATABASE_URL'))
       connection = engine.connect()
       result = connection.execute(text('SELECT 1'))
       print('✅ Database connection successful!')
       connection.close()
   except Exception as e:
       print(f'❌ Database error: {e}')
   "
   ```

3. **Expected configuration**:
   - Authentication plugin: `mysql_native_password`
   - DATABASE_URL: `mysql+pymysql://root:password@mysql-service:3306/tododb`

### Frontend Development
```bash
cd todo-frontend
npm install
npm start
```

## Namespace Information

This example deploys to the `todo-isolated` namespace for isolation from other examples.

**Useful namespace commands:**
```bash
# View all resources in the namespace
kubectl get all -n todo-isolated

# Delete all resources in the namespace
kubectl delete namespace todo-isolated

# Check namespace status
kubectl get namespaces | grep todo
```
 