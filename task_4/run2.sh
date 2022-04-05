#!/bin/sh

# serviceAccount:
#kubectl create serviceaccount sa-namespace-admin --dry-run=client -o=yaml > serviceAccount_temp.yaml
kubectl apply -f serviceAccount.yaml

# Create context in .kube/config:
export secretName=$(kubectl --namespace default get serviceaccount/sa-namespace-admin -o jsonpath='{.secrets[0].name}')
export token=$(kubectl -n default get secret $secretName -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials sa-namespace-admin --token=$token

#kubectl create rolebinding rolebinding_serviceaccount --clusterrole=admin --serviceaccount=default:sa-namespace-admin --dry-run=client -o=yaml > rolebinding_serviceaccount_temp.yaml
kubectl apply -f rolebinding_serviceaccount.yaml

# Switch to use new context:
kubectl config set-context --current --user=sa-namespace-admin

# Tests:
kubectl create deployment nginx --image=nginx
kubectl get pods
kubectl delete deployment nginx
kubectl get pods --namespace prod

kubectl config set-context --current --user=minikube