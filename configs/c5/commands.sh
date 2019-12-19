#Create pod from Selenium docker image
kubectl run kuard --generator=run-pod/v1 \--image=hub.docker.com/r/selenium/hub
#See pods
kubectl get pods
#Delete pod
kubectl delete pods/kuard
#Deploy selenium yaml pod
kubectl apply -f web_server.yaml