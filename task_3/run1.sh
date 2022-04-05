#!/bin/bash
kubectl create namespace minio
kubectl get namespace
kubectl config set-context --current --namespace=minio

kubectl apply -f pv.yaml
kubectl get pv
kubectl apply -f pvc.yaml
kubectl get pvc
kubectl get pv
kubectl apply -f deployment.yaml
kubectl get pods

# Create service minio:
kubectl expose deployment minio --name=service-minio --dry-run=client -o yaml > service-minio.yaml
kubectl apply -f service-minio.yaml

# From task_2:
kubectl apply -f ../task_2/nginx-configmap.yaml
mkdir ../task_2/canary
kubectl create deployment deploy-web-regular --image=nginx --port=80 --dry-run=client -o yaml > ../task_2/canary/deployment-web-regular_temp1.yaml
head -n -1 ../task_2/canary/deployment-web-regular_temp1.yaml > ../task_2/canary/deployment-web-regular_temp2.yaml
cat <<- EOF | tee ../task_2/canary/append.txt
        volumeMounts:
        - name: app-conf
          mountPath: /etc/nginx/conf.d
        resources: {}
      volumes:
      - name: app-conf
        configMap:
          name: nginx-configmap
EOF
cat ../task_2/canary/deployment-web-regular_temp2.yaml ../task_2/canary/append.txt > ../task_2/canary/deployment-web-regular.yaml
kubectl apply -f ../task_2/canary/deployment-web-regular.yaml
kubectl expose deployment deploy-web-regular --name=service-web-regular --dry-run=client -o yaml > ../task_2/canary/service-web-regular.yaml
kubectl apply -f ../task_2/canary/service-web-regular.yaml

# Create ingress minio:
kubectl create ingress ingress-minio \
	--annotation kubernetes.io/ingress.class=nginx \
	--rule="/=service-minio:9001" \
	--rule="/web=service-web-regular:80" \
	--dry-run=client -o yaml > ingress-minio_temp.yaml
sed 's/Exact/Prefix/g' ingress-minio_temp.yaml > ingress-minio.yaml
kubectl apply -f ingress-minio.yaml
sleep 4 # wait for pods creating
kubectl get pods -o wide

# Tests:
IP=$(minikube ip)
curl -s $IP
echo
curl -s $IP/web

# Clean:
#kubectl config set-context --current --namespace=default
#kubectl delete namespace minio
#kubectl delete pv minio-deployment-pv
