#!/bin/bash
# emptydir
kubectl delete deployment deploy-emptydir
kubectl create deployment deploy-emptydir --image=nginx --port=80 --dry-run=client -o yaml > deployment-emptyDir_temp1.yaml
head -n -1 deployment-emptyDir_temp1.yaml > deployment-emptyDir_temp2.yaml
cat <<- EOF | tee append.txt
        volumeMounts:
          - name: cache-volume
            mountPath: /emptyDir
      volumes:
        - name: cache-volume
          emptyDir: {}
EOF
cat deployment-emptyDir_temp2.yaml append.txt > deployment-emptyDir.yaml
kubectl apply -f deployment-emptyDir.yaml
kubectl get deploy
sleep 4 # wait for pod creating
kubectl get pods
pod_name=$(kubectl get pods | grep deploy-emptydir- | awk '{print $1}')
kubectl exec $pod_name -- sh -c "touch /emptyDir/file.txt"
kubectl exec $pod_name -- sh -c "ls -l /emptyDir"
kubectl delete pods $pod_name
sleep 4 # wait for pod creating
kubectl get pods
pod_name=$(kubectl get pods | grep deploy-emptydir- | awk '{print $1}')
kubectl exec $pod_name -- sh -c "ls -l /emptyDir"

# Clean:
#kubectl delete deployment deploy-emptydir
