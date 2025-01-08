## How to use this:

	Build the Docker image correctly:
When you build the image, the build context should be set to the DEV/ directory (where the Dockerfile is located). Run the following from the parent directory:

	1.	Build and Import Docker Image:
```

docker save helen-dev:latest -o helen-dev.tar
microk8s ctr image import helen-dev.tar # Import the image into your MicroK8s cluster

```

Apply the YAML:
```
microk8s kubectl apply -f helen-dev.yaml
```

Verify Deployment:
```
microk8s kubectl get pods -o wide
microk8s kubectl get svc
```

Access Your Site:
	•	Use http://<node-IP>:32564 to access your site.


Create namespace
```
microk8s kubectl create namespace development
```


Create and push the docker container
```
docker build -t helen-dev:latest .
sudo docker login # login to docker 
sudo docker tag helen-dev:latest chickenj0/helen-dev:latest # tag appropriately
sudo docker images # verify tagged image 
sudo docker push chickenj0/helen-dev:latest # push image to docker repo
```



Cert-Manager Functionality: Ensure cert-manager is installed, and the letsencrypt-prod secret is successfully created:
```
microk8s kubectl get secrets -n development
```

Ingress Class: Verify that the Ingress controller is using the public class:
```
microk8s kubectl describe ingressclass public
```

Ingress Controller: Confirm the Ingress controller is running and functional:
```
microk8s kubectl get pods -n ingress
```

