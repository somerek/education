rem Create namespace for task_4.2
kubectl create namespace prod

rem Create private keys
openssl genrsa -out deploy_view.key 2048
openssl genrsa -out deploy_edit.key 2048
openssl genrsa -out prod_view.key 2048
openssl genrsa -out prod_admin.key 2048

rem Create certificate signing requests
openssl req -new -key deploy_view.key -out deploy_view.csr -subj "/CN=deploy_view"
openssl req -new -key deploy_edit.key -out deploy_edit.csr -subj "/CN=deploy_edit"
openssl req -new -key prod_view.key -out prod_view.csr -subj "/CN=prod_view"
openssl req -new -key prod_admin.key -out prod_admin.csr -subj "/CN=prod_admin"

rem Sign the CSRs in the Kubernetes CA
openssl x509 -req -in deploy_view.csr -CA %USERPROFILE%\.minikube\ca.crt -CAkey %USERPROFILE%\.minikube\ca.key -CAcreateserial -out deploy_view.crt -days 500
openssl x509 -req -in deploy_edit.csr -CA %USERPROFILE%\.minikube\ca.crt -CAkey %USERPROFILE%\.minikube\ca.key -CAcreateserial -out deploy_edit.crt -days 500
openssl x509 -req -in prod_view.csr -CA %USERPROFILE%\.minikube\ca.crt -CAkey %USERPROFILE%\.minikube\ca.key -CAcreateserial -out prod_view.crt -days 500
openssl x509 -req -in prod_admin.csr -CA %USERPROFILE%\.minikube\ca.crt -CAkey %USERPROFILE%\.minikube\ca.key -CAcreateserial -out prod_admin.crt -days 500

rem Create user in kubernetes
kubectl config set-credentials deploy_view --client-certificate=deploy_view.crt --client-key=deploy_view.key
kubectl config set-credentials deploy_edit --client-certificate=deploy_edit.crt --client-key=deploy_edit.key
kubectl config set-credentials prod_view --client-certificate=prod_view.crt --client-key=prod_view.key
kubectl config set-credentials prod_admin --client-certificate=prod_admin.crt --client-key=prod_admin.key

rem Set context for user
kubectl config set-context context_deploy_view --cluster=minikube --user=deploy_view
kubectl config set-context context_deploy_edit --cluster=minikube --user=deploy_edit
kubectl config set-context context_prod_view --cluster=minikube --user=prod_view
kubectl config set-context context_prod_admin --cluster=minikube --user=prod_admin

rem Bind role and roleBinding to the users:
kubectl create role role_deploy_view --verb=get,list,watch --resource=pods,deployments
kubectl create rolebinding rolebinding_deploy_view --role=role_deploy_view --user=deploy_view
kubectl create role role_deploy_edit --verb=* --resource=pods,deployments
kubectl create rolebinding rolebinding_deploy_edit --role=role_deploy_edit --user=deploy_edit
kubectl apply -f role_prod_view.yaml
kubectl apply -f role_prod_admin.yaml
kubectl apply -f roleBinding_prod_view.yaml
kubectl apply -f roleBinding_prod_admin.yaml

rem TESTS:

rem Switch to use context context_deploy_view:
kubectl config use-context context_deploy_view
kubectl get all
kubectl create deployment nginx --image=nginx

rem Switch to use context context_deploy_edit:
kubectl config use-context context_deploy_edit
kubectl create deployment nginx --image=nginx
kubectl get all
kubectl delete deployment nginx

rem Switch to use context context_prod_view:
kubectl config use-context context_prod_view
kubectl get all
kubectl config set-context --current --namespace=prod
kubectl get all
kubectl create deployment nginx --image=nginx
kubectl config set-context --current --namespace=default

rem Switch to use context context_prod_admin:
kubectl config use-context context_prod_admin
kubectl get all
kubectl config set-context --current --namespace=prod
kubectl create deployment nginx --image=nginx
kubectl get all
kubectl delete deployment nginx

rem Switch to default(admin) context:
kubectl config set-context --current --namespace=default
kubectl config use-context minikube

rem Clean:
rem kubectl delete namespace prod
