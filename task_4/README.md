# Task 4
# Homework
# Task 4.1, 4.2
* Create users deploy_view and deploy_edit. Give the user deploy_view rights only to view deployments, pods. Give the user deploy_edit full rights to the objects deployments, pods.
* Create namespace prod. Create users prod_admin, prod_view. Give the user prod_admin admin rights on ns prod, give the user prod_view only view rights on namespace prod.
## Solution
You need to run the bat script
```DOS
run1.bat
```
## Result
```DOS
C:\Users\admin\28\task_4>run1.bat

C:\Users\admin\28\task_4>rem Create namespace for task_4.2

C:\Users\admin\28\task_4>kubectl create namespace prod
namespace/prod created

C:\Users\admin\28\task_4>rem Create private keys

C:\Users\admin\28\task_4>openssl genrsa -out deploy_view.key 2048

C:\Users\admin\28\task_4>openssl genrsa -out deploy_edit.key 2048

C:\Users\admin\28\task_4>openssl genrsa -out prod_view.key 2048

C:\Users\admin\28\task_4>openssl genrsa -out prod_admin.key 2048

C:\Users\admin\28\task_4>rem Create certificate signing requests

C:\Users\admin\28\task_4>openssl req -new -key deploy_view.key -out deploy_view.csr -subj "/CN=deploy_view"

C:\Users\admin\28\task_4>openssl req -new -key deploy_edit.key -out deploy_edit.csr -subj "/CN=deploy_edit"

C:\Users\admin\28\task_4>openssl req -new -key prod_view.key -out prod_view.csr -subj "/CN=prod_view"

C:\Users\admin\28\task_4>openssl req -new -key prod_admin.key -out prod_admin.csr -subj "/CN=prod_admin"

C:\Users\admin\28\task_4>rem Sign the CSRs in the Kubernetes CA

C:\Users\admin\28\task_4>openssl x509 -req -in deploy_view.csr -CA C:\Users\admin\.minikube\ca.crt -CAkey C:\Users\admin\.minikube\ca.key -CAcreateserial -out deploy_view.crt -days 500
Certificate request self-signature ok
subject=CN = deploy_view

C:\Users\admin\28\task_4>openssl x509 -req -in deploy_edit.csr -CA C:\Users\admin\.minikube\ca.crt -CAkey C:\Users\admin\.minikube\ca.key -CAcreateserial -out deploy_edit.crt -days 500
Certificate request self-signature ok
subject=CN = deploy_edit

C:\Users\admin\28\task_4>openssl x509 -req -in prod_view.csr -CA C:\Users\admin\.minikube\ca.crt -CAkey C:\Users\admin\.minikube\ca.key -CAcreateserial -out prod_view.crt -days 500
Certificate request self-signature ok
subject=CN = prod_view

C:\Users\admin\28\task_4>openssl x509 -req -in prod_admin.csr -CA C:\Users\admin\.minikube\ca.crt -CAkey C:\Users\admin\.minikube\ca.key -CAcreateserial -out prod_admin.crt -days 500
Certificate request self-signature ok
subject=CN = prod_admin

C:\Users\admin\28\task_4>rem Create user in kubernetes

C:\Users\admin\28\task_4>kubectl config set-credentials deploy_view --client-certificate=deploy_view.crt --client-key=deploy_view.key
User "deploy_view" set.

C:\Users\admin\28\task_4>kubectl config set-credentials deploy_edit --client-certificate=deploy_edit.crt --client-key=deploy_edit.key
User "deploy_edit" set.

C:\Users\admin\28\task_4>kubectl config set-credentials prod_view --client-certificate=prod_view.crt --client-key=prod_view.key
User "prod_view" set.

C:\Users\admin\28\task_4>kubectl config set-credentials prod_admin --client-certificate=prod_admin.crt --client-key=prod_admin.key
User "prod_admin" set.

C:\Users\admin\28\task_4>rem Set context for user

C:\Users\admin\28\task_4>kubectl config set-context context_deploy_view --cluster=minikube --user=deploy_view
Context "context_deploy_view" created.

C:\Users\admin\28\task_4>kubectl config set-context context_deploy_edit --cluster=minikube --user=deploy_edit
Context "context_deploy_edit" created.

C:\Users\admin\28\task_4>kubectl config set-context context_prod_view --cluster=minikube --user=prod_view
Context "context_prod_view" created.

C:\Users\admin\28\task_4>kubectl config set-context context_prod_admin --cluster=minikube --user=prod_admin
Context "context_prod_admin" created.

C:\Users\admin\28\task_4>rem Bind role and roleBinding to the users:

C:\Users\admin\28\task_4>kubectl create role role_deploy_view --verb=get,list,watch --resource=pods,deployments
role.rbac.authorization.k8s.io/role_deploy_view created

C:\Users\admin\28\task_4>kubectl create rolebinding rolebinding_deploy_view --role=role_deploy_view --user=deploy_view
rolebinding.rbac.authorization.k8s.io/rolebinding_deploy_view created

C:\Users\admin\28\task_4>kubectl create role role_deploy_edit --verb=* --resource=pods,deployments
role.rbac.authorization.k8s.io/role_deploy_edit created

C:\Users\admin\28\task_4>kubectl create rolebinding rolebinding_deploy_edit --role=role_deploy_edit --user=deploy_edit
rolebinding.rbac.authorization.k8s.io/rolebinding_deploy_edit created

C:\Users\admin\28\task_4>kubectl apply -f role_prod_view.yaml
role.rbac.authorization.k8s.io/role_prod_view created

C:\Users\admin\28\task_4>kubectl apply -f role_prod_admin.yaml
role.rbac.authorization.k8s.io/role_prod_admin created

C:\Users\admin\28\task_4>kubectl apply -f roleBinding_prod_view.yaml
rolebinding.rbac.authorization.k8s.io/rolebinding_prod_view created

C:\Users\admin\28\task_4>kubectl apply -f roleBinding_prod_admin.yaml
rolebinding.rbac.authorization.k8s.io/rolebinding_prod_admin created

C:\Users\admin\28\task_4>rem TESTS:

C:\Users\admin\28\task_4>rem Switch to use context context_deploy_edit:

C:\Users\admin\28\task_4>kubectl config use-context context_deploy_edit
Switched to context "context_deploy_edit".

C:\Users\admin\28\task_4>kubectl create deployment nginx --image=nginx
deployment.apps/nginx created

C:\Users\admin\28\task_4>kubectl get all
NAME                         READY   STATUS              RESTARTS   AGE
pod/nginx-85b98978db-6n8wd   0/1     ContainerCreating   0          1s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   0/1     1            0           1s
Error from server (Forbidden): replicationcontrollers is forbidden: User "deploy_edit" cannot list resource "replicationcontrollers" in API group "" in the namespace "default"
Error from server (Forbidden): services is forbidden: User "deploy_edit" cannot list resource "services" in API group "" in the namespace "default"
Error from server (Forbidden): daemonsets.apps is forbidden: User "deploy_edit" cannot list resource "daemonsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): replicasets.apps is forbidden: User "deploy_edit" cannot list resource "replicasets" in API group "apps" in the namespace "default"
Error from server (Forbidden): statefulsets.apps is forbidden: User "deploy_edit" cannot list resource "statefulsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): horizontalpodautoscalers.autoscaling is forbidden: User "deploy_edit" cannot list resource "horizontalpodautoscalers" in API group "autoscaling" in the namespace "default"
Error from server (Forbidden): cronjobs.batch is forbidden: User "deploy_edit" cannot list resource "cronjobs" in API group "batch" in the namespace "default"
Error from server (Forbidden): jobs.batch is forbidden: User "deploy_edit" cannot list resource "jobs" in API group "batch" in the namespace "default"

C:\Users\admin\28\task_4>rem Switch to use context context_deploy_view:

C:\Users\admin\28\task_4>kubectl config use-context context_deploy_view
Switched to context "context_deploy_view".

C:\Users\admin\28\task_4>kubectl get all
NAME                         READY   STATUS              RESTARTS   AGE
pod/nginx-85b98978db-6n8wd   0/1     ContainerCreating   0          1s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   0/1     1            0           1s
Error from server (Forbidden): replicationcontrollers is forbidden: User "deploy_view" cannot list resource "replicationcontrollers" in API group "" in the namespace "default"
Error from server (Forbidden): services is forbidden: User "deploy_view" cannot list resource "services" in API group "" in the namespace "default"
Error from server (Forbidden): daemonsets.apps is forbidden: User "deploy_view" cannot list resource "daemonsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): replicasets.apps is forbidden: User "deploy_view" cannot list resource "replicasets" in API group "apps" in the namespace "default"
Error from server (Forbidden): statefulsets.apps is forbidden: User "deploy_view" cannot list resource "statefulsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): horizontalpodautoscalers.autoscaling is forbidden: User "deploy_view" cannot list resource "horizontalpodautoscalers" in API group "autoscaling" in the namespace "default"
Error from server (Forbidden): cronjobs.batch is forbidden: User "deploy_view" cannot list resource "cronjobs" in API group "batch" in the namespace "default"
Error from server (Forbidden): jobs.batch is forbidden: User "deploy_view" cannot list resource "jobs" in API group "batch" in the namespace "default"

C:\Users\admin\28\task_4>kubectl create deployment nginx --image=nginx
error: failed to create deployment: deployments.apps is forbidden: User "deploy_view" cannot create resource "deployments" in API group "apps" in the namespace "default"

C:\Users\admin\28\task_4>rem Switch to use context context_prod_admin:

C:\Users\admin\28\task_4>kubectl config use-context context_prod_admin
Switched to context "context_prod_admin".

C:\Users\admin\28\task_4>kubectl get all
Error from server (Forbidden): pods is forbidden: User "prod_admin" cannot list resource "pods" in API group "" in the namespace "default"
Error from server (Forbidden): replicationcontrollers is forbidden: User "prod_admin" cannot list resource "replicationcontrollers" in API group "" in the namespace "default"
Error from server (Forbidden): services is forbidden: User "prod_admin" cannot list resource "services" in API group "" in the namespace "default"
Error from server (Forbidden): daemonsets.apps is forbidden: User "prod_admin" cannot list resource "daemonsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): deployments.apps is forbidden: User "prod_admin" cannot list resource "deployments" in API group "apps" in the namespace "default"
Error from server (Forbidden): replicasets.apps is forbidden: User "prod_admin" cannot list resource "replicasets" in API group "apps" in the namespace "default"
Error from server (Forbidden): statefulsets.apps is forbidden: User "prod_admin" cannot list resource "statefulsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): horizontalpodautoscalers.autoscaling is forbidden: User "prod_admin" cannot list resource "horizontalpodautoscalers" in API group "autoscaling" in the namespace "default"
Error from server (Forbidden): cronjobs.batch is forbidden: User "prod_admin" cannot list resource "cronjobs" in API group "batch" in the namespace "default"
Error from server (Forbidden): jobs.batch is forbidden: User "prod_admin" cannot list resource "jobs" in API group "batch" in the namespace "default"

C:\Users\admin\28\task_4>kubectl config set-context --current --namespace=prod
Context "context_prod_admin" modified.

C:\Users\admin\28\task_4>kubectl create deployment nginx --image=nginx
deployment.apps/nginx created

C:\Users\admin\28\task_4>kubectl get all
NAME                         READY   STATUS              RESTARTS   AGE
pod/nginx-85b98978db-p2p64   0/1     ContainerCreating   0          1s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   0/1     1            0           1s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-85b98978db   1         1         0       1s

C:\Users\admin\28\task_4>kubectl config set-context --current --namespace=default
Context "context_prod_admin" modified.

C:\Users\admin\28\task_4>rem Switch to use context context_prod_view:

C:\Users\admin\28\task_4>kubectl config use-context context_prod_view
Switched to context "context_prod_view".

C:\Users\admin\28\task_4>kubectl get all
Error from server (Forbidden): pods is forbidden: User "prod_view" cannot list resource "pods" in API group "" in the namespace "default"
Error from server (Forbidden): replicationcontrollers is forbidden: User "prod_view" cannot list resource "replicationcontrollers" in API group "" in the namespace "default"
Error from server (Forbidden): services is forbidden: User "prod_view" cannot list resource "services" in API group "" in the namespace "default"
Error from server (Forbidden): daemonsets.apps is forbidden: User "prod_view" cannot list resource "daemonsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): deployments.apps is forbidden: User "prod_view" cannot list resource "deployments" in API group "apps" in the namespace "default"
Error from server (Forbidden): replicasets.apps is forbidden: User "prod_view" cannot list resource "replicasets" in API group "apps" in the namespace "default"
Error from server (Forbidden): statefulsets.apps is forbidden: User "prod_view" cannot list resource "statefulsets" in API group "apps" in the namespace "default"
Error from server (Forbidden): horizontalpodautoscalers.autoscaling is forbidden: User "prod_view" cannot list resource "horizontalpodautoscalers" in API group "autoscaling" in the namespace "default"
Error from server (Forbidden): cronjobs.batch is forbidden: User "prod_view" cannot list resource "cronjobs" in API group "batch" in the namespace "default"
Error from server (Forbidden): jobs.batch is forbidden: User "prod_view" cannot list resource "jobs" in API group "batch" in the namespace "default"

C:\Users\admin\28\task_4>kubectl config set-context --current --namespace=prod
Context "context_prod_view" modified.

C:\Users\admin\28\task_4>kubectl get all
NAME                         READY   STATUS              RESTARTS   AGE
pod/nginx-85b98978db-p2p64   0/1     ContainerCreating   0          2s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   0/1     1            0           2s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-85b98978db   1         1         0       2s

C:\Users\admin\28\task_4>kubectl create deployment nginx --image=nginx
error: failed to create deployment: deployments.apps is forbidden: User "prod_view" cannot create resource "deployments" in API group "apps" in the namespace "prod"

C:\Users\admin\28\task_4>rem Switch to default(admin) context:

C:\Users\admin\28\task_4>kubectl config set-context --current --namespace=default
Context "context_prod_view" modified.

C:\Users\admin\28\task_4>kubectl config use-context minikube
Switched to context "minikube".

C:\Users\admin\28\task_4>rem Clean:

C:\Users\admin\28\task_4>rem kubectl delete namespace prod

C:\Users\admin\28\task_4>
```
# Task 4.3
* Create a serviceAccount sa-namespace-admin. Grant full rights to namespace default. Create context, authorize using the created sa, check accesses.
## Solution
You need to run the bat script
```bash
./run2.sh
```
## Result
```bash
$ ./run2.sh
serviceaccount/sa-namespace-admin configured
User "sa-namespace-admin" set.
rolebinding.rbac.authorization.k8s.io/rolebinding_serviceaccount configured
Context "minikube" modified.
deployment.apps/nginx created
NAME                     READY   STATUS              RESTARTS   AGE
nginx-85b98978db-dtj5w   0/1     ContainerCreating   0          0s
deployment.apps "nginx" deleted
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:sa-namespace-admin" cannot list resource "pods" in API group "" in the namespace "prod"
Context "minikube" modified.
```

### Check what I can do
```bash
kubectl auth can-i create deployments --namespace kube-system
```
### Sample output
```bash
yes
```
### Configure user authentication using x509 certificates
### Create private key
```bash
openssl genrsa -out k8s_user.key 2048
```
### Create a certificate signing request
```bash
openssl req -new -key k8s_user.key \
-out k8s_user.csr \
-subj "/CN=k8s_user"
```
### Sign the CSR in the Kubernetes CA. We have to use the CA certificate and the key, which are usually in /etc/kubernetes/pki. But since we use minikube, the certificates will be on the host machine in ~/.minikube
```bash
openssl x509 -req -in k8s_user.csr \
-CA ~/.minikube/ca.crt \
-CAkey ~/.minikube/ca.key \
-CAcreateserial \
-out k8s_user.crt -days 500
```
### Create user in kubernetes
```bash
kubectl config set-credentials k8s_user \
--client-certificate=k8s_user.crt \
--client-key=k8s_user.key
```
### Set context for user
```bash
kubectl config set-context k8s_user \
--cluster=minikube --user=k8s_user
```
### Edit ~/.kube/config
```bash
Change path
- name: k8s_user
  user:
    client-certificate: C:\Users\Andrey_Trusikhin\educ\k8s_user.crt
    client-key: C:\Users\Andrey_Trusikhin\educ\k8s_user.key
contexts:
- context:
    cluster: minikube
    user: k8s_user
  name: k8s_user
```
### Switch to use new context
```bash
kubectl config use-context k8s_user
```
### Check privileges
```bash
kubectl get node
kubectl get pod
```
### Sample output
```bash
Error from server (Forbidden): pods is forbidden: User "k8s_user" cannot list resource "pods" in API group "" in the namespace "default"
```
### Switch to default(admin) context
```bash
kubectl config use-context minikube
```
### Bind role and clusterrole to the user
```bash
kubectl apply -f binding.yaml
```
### Check output
```bash
kubectl get pod
```
Now we can see pods


### Homework
* Create users deploy_view and deploy_edit. Give the user deploy_view rights only to view deployments, pods. Give the user deploy_edit full rights to the objects deployments, pods.
* Create namespace prod. Create users prod_admin, prod_view. Give the user prod_admin admin rights on ns prod, give the user prod_view only view rights on namespace prod.
* Create a serviceAccount sa-namespace-admin. Grant full rights to namespace default. Create context, authorize using the created sa, check accesses.