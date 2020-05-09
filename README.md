# Welcome to ProxySQL on K8s

Tools that will be used:

- KVM / Libvirt
- Kubectl
- Minikube
- Helm

## Installing tools (note packaged installation is also an option). 

These steps assume "/usr/local/bin" is defined in your PATH and you are using Linux :)

### Installing Kubectl

#### Detailed install

- https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux

#### TL;DR

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
```

### Installing Minikube (KVM,VirtualBox,VMWare or similar should be pre-installed)

#### Detailed install

- https://kubernetes.io/docs/tasks/tools/install-minikube/

#### TL;DR

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
&& chmod +x minikube
sudo mv ./minikube /usr/local/bin/
```

### Installing Helm

#### Detailed install

- https://helm.sh/docs/intro/install/

#### TL;DR

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Configuring environment

### Minikube

```
minikube config set memory 8192
minikube config set cpus 3
minikube config set disk-size 30000MB
minikube config set vm-driver kvm2
minikube start 
minikube status
```

### Add dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
minikube addons enable dashboard

# Get dashboard URL (ctrl+c to exit if stuck)
minikube dashboard --url

🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
http://127.0.0.1:45536/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

# Start dashboard on local IP (forwarded from within Minikube VM) - default port is 8001
kubectl proxy --address=192.168.1.28 --accept-hosts='^.*'
```

Combining the URL and the `kubectl proxy` command the url is: http://192.168.1.28:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

## Deploying with Helm

### Install MySQL with bitnami charts

Note: You can configure custom settings (root password / number of slaves / etc. in mysql/values.yaml

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mysql-8 -f ./mysql/values.yaml bitnami/mysql

# Get password for MySQL
echo Password : $(kubectl get secret --namespace default mysql-8 -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
Password : XHCO2ydDXj
```

### ProxySQL deployment options overview

- Deploy a ProxySQL "layer" (standalone config)
- Deploy a ProxySQL "layer" with a controller (aka core / satellite)
- Deploy ProxySQL as a sidecar
- Deploy ProxySQL Cascaded i.e. ProxySQL "layer" and ProxySQL as a sidecar

#### Deploy ProxySQL Layer

##### Install ProxySQL (proxy layer with service)

```
helm install proxysql-cluster ./proxysql-cluster
```

##### Change settings and re-deploy

```
vi proxysql-cluster/files/proxysql.cnf 
helm upgrade proxysql-cluster ./proxysql-cluster
```

Optionally do a rolling restart (note, templates are configured to re-deploy on config map changes)

```
kubectl rollout restart deployment/proxysql-cluster
```

##### Delete `proxysql-cluster` deployment

```
helm delete proxysql-cluster
```

#### Deploy sidecar 

```
helm install proxysql-sidecar ./proxysql-sidecar
```

#### Deploy core / satelite 

```
helm install proxysql-cluster-controller ./proxysql-cluster-controller
helm install proxysql-cluster-passive ./proxysql-cluster-passive
```

#### Deploy sidecar that connects to `proxysql-cluster-passive` (i.e. Cascaded ProxySQL)

```
helm install proxysql-sidecar-cascade ./proxysql-sidecar-cascade
```

## Useful commands

### Helm

```
helm install <releasename> <path>
helm upgrade <releasename> <path>
helm delete <releasename>
```

### Kubectl

```
kubectl get services
kubectl get pods
kubectl get deployment
kubectl get pods --all-namespaces
kubectl describe service <servicename>
kubectl rollout restart deployment/proxysql-cluster
```

### Minicube

```
minikube start
minikube delete
```