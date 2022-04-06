#!/bin/bash

# NFS pv/pvc
kubectl apply -f ./nfs/pv-nfs.yaml
kubectl get pv
kubectl apply -f ./nfs/pvc-nfs.yaml
kubectl get pvc
kubectl get pv
#kubectl create deployment deploy-web-nfs --image=nginx --dry-run=client -o yaml > ./nfs/deployment-web-nfs_temp.yaml
kubectl apply -f ./nfs/deployment-web-nfs.yaml
kubectl get deploy
sleep 4 # wait for pod creating
kubectl get pods -o=wide

# Tests:
pod_name=$(kubectl get pods | grep deploy-web-nfs- | awk '{print $1}')
kubectl exec $pod_name -- sh -c "touch /nfs-data/\"$(date)\".txt"
kubectl exec $pod_name -- sh -c "ls -l /nfs-data"

# Delete:
kubectl delete deployment deploy-web-nfs
kubectl delete pvc pvc-nfs
kubectl delete pv pv-nfs
