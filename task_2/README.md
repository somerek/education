# Task 2

# Homework
## Task 2.1
In Minikube in namespace kube-system, there are many different pods running. Your task is to figure out who creates them, and who makes sure they are running (restores them after deletion).
## Solution
1. If you want to know what service controll each pod in kube-system namespace - you can run one command:
```bash
for i in $(kubectl -n kube-system get pods | grep -v NAME | awk '{print $1}'); do echo $i; kubectl -n kube-system describe pods $i | grep "Controlled By:"; done
```
The answer is 
```bash
$ for i in $(kubectl -n kube-system get pods | grep -v NAME | awk '{print $1}'); do echo $i; kubectl -n kube-system describe pods $i | grep "Controlled By:"; done
coredns-64897985d-dn5bp
Controlled By:  ReplicaSet/coredns-64897985d
etcd-minikube
Controlled By:  Node/minikube
kube-apiserver-minikube
Controlled By:  Node/minikube
kube-controller-manager-minikube
Controlled By:  Node/minikube
kube-proxy-ppn45
Controlled By:  DaemonSet/kube-proxy
kube-scheduler-minikube
Controlled By:  Node/minikube
metrics-server-6b76bd68b6-mf9rl
Controlled By:  ReplicaSet/metrics-server-6b76bd68b6
storage-provisioner
```
2. If you want to know uid of namespace kube-system, the second command is:
```bash
$ kubectl get namespace kube-system -o yaml | grep uid
  uid: 7ccc56b1-cfff-464f-9fc5-b6df69cb01f2
```
3. [Documentation](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/#synopsis "kubelet synopsis") says that **kubelet** ensures that the containers are running and healthy.
## Task 2.2
Implement Canary deployment of an application via Ingress. Traffic to canary deployment should be redirected if you add "canary:always" in the header, otherwise it should go to regular deployment.
Set to redirect a percentage of traffic to canary deployment.
## Solution
You need to run the bash script
```bash
./run.sh
```
Output:
```bash
$ ./run.sh
namespace/canary created
NAME                   STATUS   AGE
canary                 Active   0s
default                Active   4d2h
ingress-nginx          Active   3d23h
kube-node-lease        Active   4d2h
kube-public            Active   4d2h
kube-system            Active   4d2h
kubernetes-dashboard   Active   4d2h
Context "minikube" modified.
configmap/nginx-configmap created
NAME               DATA   AGE
kube-root-ca.crt   1      1s
nginx-configmap    1      0s
        volumeMounts:
        - name: app-conf
          mountPath: /etc/nginx/conf.d
        resources: {}
      volumes:
      - name: app-conf
        configMap:
          name: nginx-configmap
deployment.apps/deploy-web-regular created
deployment.apps/deploy-web-canary created
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
deploy-web-canary    0/1     1            0           0s
deploy-web-regular   0/1     1            0           1s
NAME                                  READY   STATUS              RESTARTS   AGE
deploy-web-canary-c7cd4f67d-8947q     0/1     ContainerCreating   0          0s
deploy-web-regular-85bf8b5844-brzsc   0/1     ContainerCreating   0          1s
service/service-web-regular created
service/service-web-canary created
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service-web-canary    ClusterIP   10.101.154.165   <none>        80/TCP    1s
service-web-regular   ClusterIP   10.104.89.207    <none>        80/TCP    1s
ingress.networking.k8s.io/ingress-web-regular created
ingress.networking.k8s.io/ingress-web-canary created
NAME                  CLASS    HOSTS   ADDRESS   PORTS   AGE
ingress-web-canary    <none>   *                 80      0s
ingress-web-regular   <none>   *                 80      1s
NAME                                  READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
deploy-web-canary-c7cd4f67d-8947q     1/1     Running   0          6s    172.17.0.6   minikube   <none>           <none>
deploy-web-regular-85bf8b5844-brzsc   1/1     Running   0          7s    172.17.0.5   minikube   <none>           <none>
20 with_tag.txt
3 without_tag.txt
Context "minikube" modified.
namespace "canary" deleted
```
It means that with tag "canary" was 3 answer from canary app (other answers was from regular app, 20 attempts in total, canary-weight=20) and without tag "canary" was all 20 answers.
That's all!

### ConfigMap & Secrets
```bash
kubectl create secret generic connection-string --from-literal=DATABASE_URL=postgres://connect --dry-run=client -o yaml > secret.yaml
kubectl create configmap user --from-literal=firstname=firstname --from-literal=lastname=lastname --dry-run=client -o yaml > cm.yaml
kubectl apply -f secret.yaml
kubectl apply -f cm.yaml
kubectl apply -f pod.yaml
```
## Check env in pod
```bash
kubectl exec -it nginx -- bash
printenv
```
### Sample output (find our env)
```bash
Unable to use a TTY - input is not a terminal or the right kind of file
printenv
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
DATABASE_URL=postgres://connect
HOSTNAME=nginx
PWD=/
PKG_RELEASE=1~buster
HOME=/root
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
NJS_VERSION=0.6.2
SHLVL=1
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
lastname=lastname
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
firstname=firstname
NGINX_VERSION=1.21.3
_=/usr/bin/printenv
```
### Create deployment with simple application
```bash
kubectl apply -f nginx-configmap.yaml
kubectl apply -f deployment.yaml
```
### Get pod ip address
```bash
kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
web-5584c6c5c6-6wmdx   1/1     Running   0          4m47s   172.17.0.11   minikube   <none>           <none>
web-5584c6c5c6-l4drg   1/1     Running   0          4m47s   172.17.0.10   minikube   <none>           <none>
web-5584c6c5c6-xn466   1/1     Running   0          4m47s   172.17.0.9    minikube   <none>           <none>
```
* Try connect to pod with curl (curl pod_ip_address). What happens?
* From you PC
* From minikube (minikube ssh)
* From another pod (kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash)
### Create service (ClusterIP)
The command that can be used to create a manifest template
```bash
kubectl expose deployment/web --type=ClusterIP --dry-run=client -o yaml > service_template.yaml
```
Apply manifest
```bash
kubectl apply -f service_template.yaml
```
Get service CLUSTER-IP
```bash
kubectl get svc
```
### Sample output
```bash
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   20h
web          ClusterIP   10.100.170.236   <none>        80/TCP    28s
```
* Try connect to service (curl service_ip_address). What happens?

* From you PC
* From minikube (minikube ssh) (run the command several times)
* From another pod (kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash) (run the command several times)
### NodePort
```bash
kubectl apply -f service-nodeport.yaml
kubectl get service
```
### Sample output
```bash
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        20h
web          ClusterIP   10.100.170.236   <none>        80/TCP         15m
web-np       NodePort    10.101.147.109   <none>        80:30682/TCP   8s
```
Note how port is specified for a NodePort service
### Checking the availability of the NodePort service type
```bash
minikube ip
curl <minikube_ip>:<nodeport_port>
```
### Headless service
```bash
kubectl apply -f service-headless.yaml
```
### DNS
Connect to any pod
```bash
cat /etc/resolv.conf
```
Compare the IP address of the DNS server in the pod and the DNS service of the Kubernetes cluster.
* Compare headless and clusterip
Inside the pod run nslookup to normal clusterip and headless. Compare the results.
You will need to create pod with dnsutils.
### [Ingress](https://kubernetes.github.io/ingress-nginx/deploy/#minikube)
Enable Ingress controller
```bash
minikube addons enable ingress
```
Let's see what the ingress controller creates for us
```bash
kubectl get pods -n ingress-nginx
kubectl get pod $(kubectl get pod -n ingress-nginx|grep ingress-nginx-controller|awk '{print $1}') -n ingress-nginx -o yaml
```
Create Ingress
```bash
kubectl apply -f ingress.yaml
curl $(minikube ip)
```
### Homework
* In Minikube in namespace kube-system, there are many different pods running. Your task is to figure out who creates them, and who makes sure they are running (restores them after deletion).

* Implement Canary deployment of an application via Ingress. Traffic to canary deployment should be redirected if you add "canary:always" in the header, otherwise it should go to regular deployment.
Set to redirect a percentage of traffic to canary deployment.