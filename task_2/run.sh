#!/bin/bash
# Create namespace canary:
kubectl create namespace canary
kubectl get namespace
kubectl config set-context --current --namespace=canary

# Original nginx-configmap.yaml by course author:
kubectl apply -f nginx-configmap.yaml
kubectl get cm
# Create deployments:
#kubectl create deployment deploy-web-regular --image=nginx --port=80 --dry-run=client -o yaml > canary/deployment-web-regular.yaml
#kubectl create deployment deploy-web-canary --image=nginx --port=80 --dry-run=client -o yaml > canary/deployment-web-canary.yaml
# Add volumeMounts and configMap manually:
#        volumeMounts:
#        - name: app-conf
#          mountPath: /etc/nginx/conf.d
#        resources: {}
#      volumes:
#      - name: app-conf
#        configMap:
#          name: nginx-configmap
kubectl apply -f canary/deployment-web-regular.yaml
kubectl apply -f canary/deployment-web-canary.yaml
kubectl get deploy
kubectl get pods
# Create services:
kubectl expose deployment deploy-web-regular --name=service-web-regular --dry-run=client -o yaml > canary/service-web-regular.yaml
kubectl expose deployment deploy-web-canary --name=service-web-canary --dry-run=client -o yaml > canary/service-web-canary.yaml
kubectl apply -f canary/service-web-regular.yaml
kubectl apply -f canary/service-web-canary.yaml
kubectl get svc

# Create ingress:
kubectl create ingress ingress-web-regular --annotation kubernetes.io/ingress.class=nginx \
        --rule="/=service-web-regular:80" --dry-run=client -o yaml > canary/ingress-web-regular.yaml
kubectl create ingress ingress-web-canary \
        --annotation kubernetes.io/ingress.class=nginx \
        --annotation nginx.ingress.kubernetes.io/canary=true \
        --annotation nginx.ingress.kubernetes.io/canary-by-header=canary \
        --annotation nginx.ingress.kubernetes.io/canary-weight=20 \
        --rule="/=service-web-canary:80" --dry-run=client -o yaml > canary/ingress-web-canary.yaml
kubectl apply -f canary/ingress-web-regular.yaml
kubectl apply -f canary/ingress-web-canary.yaml
kubectl get ingress
sleep 1 # wait for pods creating
kubectl get pods -o wide

# Test:
IP=$(minikube ip)
for i in {1..20}
do
curl -s -H "canary:always" $IP| grep canary >> with_tag.txt
curl -s $IP| grep canary >> without_tag.txt
done
wc -l with_tag.txt
wc -l without_tag.txt
rm with_tag.txt
rm without_tag.txt

# Clean:
kubectl config set-context --current --namespace=default
kubectl delete namespace canary
