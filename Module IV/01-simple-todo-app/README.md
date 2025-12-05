# Simple Todo Application

This is a simple todo application that demonstrates a full-stack application deployment on Kubernetes with:

- **Frontend**: React application served by Nginx
- **Backend**: FastAPI application with REST endpoints
- **Database**: MySQL 8.0 with native password authentication (ephemeral storage)
- **Deployment**: Kubernetes manifests with NodePort services for external access

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Todo Frontend │    │   Todo Backend  │    │     MySQL       │
│   (React/Nginx) │───▶│    (FastAPI)    │───▶│   (Database)    │
│   Port: 30000   │    │   Port: 30001   │    │   Port: 30306   │
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
   minikube service todo-frontend-service -n todo-basic
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
   - MySQL Database: `<MINIKUBE_IP>:30306`
   - API Documentation: `<MINIKUBE_IP>:30001/docs`
   
   **Note**: The frontend automatically proxies API calls to `/api/*` to the backend service internally.

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

### Database Connection Issues
If you encounter `'cryptography' package is required for sha256_password or caching_sha2_password auth methods`:

1. **Check MySQL authentication method**:
   ```bash
   kubectl exec -n todo-basic deployment/mysql-deployment -- mysql -u root -ppassword -e "SELECT @@default_authentication_plugin;"
   ```

2. **Verify backend DATABASE_URL**:
   ```bash
   kubectl exec -n todo-basic deployment/todo-backend-deployment -- env | grep DATABASE_URL
   ```

3. **Expected values**:
   - Authentication plugin: `mysql_native_password`
   - DATABASE_URL: `mysql+pymysql://root:password@mysql-service:3306/tododb`

### Frontend Development
```bash
cd todo-frontend
npm install
npm start
```

## Namespace Information

This example deploys to the `todo-basic` namespace for isolation from other examples.

**Useful namespace commands:**
```bash
# View all resources in the namespace
kubectl get all -n todo-basic

# Delete all resources in the namespace
kubectl delete namespace todo-basic

# Check namespace status
kubectl get namespaces | grep todo
```
