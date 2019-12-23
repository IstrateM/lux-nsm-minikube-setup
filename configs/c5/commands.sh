#Create pod from Selenium docker image
kubectl run kuard --generator=run-pod/v1 \--image=hub.docker.com/r/selenium/hub
#See pods
kubectl get pods
#Delete pod
kubectl delete pods/kuard
kubectl delete -f kuard.yaml
#Deploy selenium yaml pod
kubectl apply -f kuard.yaml
#Get pod details <kubectl describe pods <pod_name>>
kubectl describe pods kuard
#Port forwarding
kubectl port-forward kuard 8080:8080