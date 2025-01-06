## How to use this:

	Build the Docker image correctly:
When you build the image, the build context should be set to the DEV/ directory (where the Dockerfile is located). Run the following from the parent directory:

	1.	Build and Import Docker Image:
```
docker build -t helen-prod:latest .
docker save helen-prod:latest -o helen-prod.tar
microk8s ctr image import helen-prod.tar # Import the image into your MicroK8s cluster:
```

	2.	Apply the YAML:
```
microk8s kubectl apply -f helen-prod.yaml
```

	3.	Verify Deployment:
```
microk8s kubectl get pods -o wide
microk8s kubectl get svc
```

	4.	Access Your Site:
	•	Use http://<node-IP>:32565 to access your site.
