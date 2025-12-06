# Logo Setup Instructions

To complete the UI setup:

1. Save the South East European University logo image as `public/seeu-logo.png`
2. The image should be in PNG format for best quality
3. Recommended dimensions: 400px width or larger for crisp display
4. The image will be automatically resized to fit the container

The frontend code is already updated to display:
- University logo at the top
- Course name: "Containerized Architecture" 
- Description: "Sample todo application - for educational purposes"

After copying the logo file, rebuild the frontend:
```bash
cd todo-frontend
docker build -t todo-frontend:v4 .
cd ..
minikube image load todo-frontend:v4
```

Then update the deployment to use v4 and apply:
```bash
kubectl apply -f k8s/todo-frontend.yaml
```