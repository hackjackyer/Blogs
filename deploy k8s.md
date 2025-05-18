# k8s

## install k8s with centos9

>https://infotechys.com/install-a-kubernetes-cluster-on-rhel-9/

```bash

centos9s1   52:54:00:a1:66:40
centos9s2   52:54:00:e4:d1:14
centos9s3   52:54:00:0e:6e:94

net.xml
<network>
  <name>default</name>
  <uuid>4b9409c0-1406-413d-b20e-c75dc5ab78bb</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:c9:b2:e4'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
      <host mac='52:54:00:a1:66:40' name='centos9s1' ip='192.168.122.101'/>
      <host mac='52:54:00:e4:d1:14' name='centos9s2' ip='192.168.122.102'/>
      <host mac='52:54:00:0e:6e:94' name='centos9s3' ip='192.168.122.103'/>
    </dhcp>
  </ip>
</network>

cat >> /etc/hosts << EOF
192.168.122.101 master-101
192.168.122.102 node-102
192.168.122.103 node-103
EOF
cat /etc/hosts

hostnamectl set-hostname master-101
hostnamectl set-hostname node-102
hostnamectl set-hostname node-103


sudo dnf install kernel-devel-$(uname -r) -y

sudo modprobe br_netfilter
sudo modprobe ip_vs
sudo modprobe ip_vs_rr
sudo modprobe ip_vs_wrr
sudo modprobe ip_vs_sh
sudo modprobe overlay

cat > /etc/modules-load.d/kubernetes.conf << EOF
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

cat > /etc/sysctl.d/kubernetes.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

# sudo swapoff -a
# sed -e '/swap/s/^/#/g' -i /etc/fstab

# sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf config-manager --add-repo https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo
sed -i s@download.docker.com@mirrors.tuna.tsinghua.edu.cn/docker-ce@g /etc/yum.repos.d/docker-ce.repo

sudo dnf makecache
sudo dnf -y install containerd.io vim

cat /etc/containerd/config.toml
sudo sh -c "containerd config default > /etc/containerd/config.toml" ; cat /etc/containerd/config.toml

sudo vim /etc/containerd/config.toml
# SystemdCgroup = true


sudo systemctl enable --now containerd.service
sudo systemctl reboot
sudo systemctl status containerd.service

dnf install firewalld -y
systemctl enable firewalld
systemctl start firewalld
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10251/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10252/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10255/tcp
sudo firewall-cmd --zone=public --permanent --add-port=5473/tcp
sudo firewall-cmd --reload

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
dnf erase kubelet kubeadm kubectl -y
dnf makecache; dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet.service

# on master node
# 需要科学
sudo kubeadm config images pull
# 制定版本
sudo kubeadm config images pull --kubernetes-version=v1.30.3
# 用其他源
sudo kubeadm config images pull --image-repository=registry.aliyuncs.com/google-containers
--image-repository=registry.aliyuncs.com/google-containers --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.18.5

sudo kubeadm init --pod-network-cidr=10.244.0.0/16
### 输出
# Your Kubernetes control-plane has initialized successfully!

# To start using your cluster, you need to run the following as a regular user:

#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

#   export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 192.168.122.101:6443 --token h3ti4f.vo8tccvofx375b02 \
# 	--discovery-token-ca-cert-hash sha256:65964bf6890555c38ff01bb95700c143f067d49b8a0a8087b065f25e216823c3
## 输出结束

# 非root用户执行这个
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# root用户直接执行这个
export KUBECONFIG=/etc/kubernetes/admin.conf


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.244.0.0\/16/g' custom-resources.yaml

kubectl create -f custom-resources.yaml

# 这里要根据网络情况，等5-10分钟。可以用这个命令查看各个pod的状态。
kubectl get pods --all-namespaces


# 获取接入命令
sudo kubeadm token create --print-join-command
# kubeadm join 192.168.122.101:6443 --token 3wgcpe.31ul8t0qsw4jxgu7 --discovery-token-ca-cert-hash sha256:04e835981760e20a81e067a3ed71cafd114145aa69563bc79246fb31ef193bf9
# 工作节点接入
sudo kubeadm join <MASTER_IP>:<MASTER_PORT> --token <TOKEN> --discovery-token-ca-cert-hash <DISCOVERY_TOKEN_CA_CERT_HASH>

## 命令

kubectl describe node master-101

kubectl get pods --all-namespaces

journalctl -u kubelet -f


kubectl patch svc <service-name> -p '{"spec": {"type": "NodePort", "ports": [{"port": <service-port>, "nodePort": <node-port>}]}}}'

kubectl patch svc nginx-service -p '{"spec": {"type": "NodePort"}}'


kubectl patch svc nginx-service -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "nodePort": 80}]}}'
# 确认 Pod 状态：
kubectl describe pod nginx-deployment-7c79c4bf97-xsvnj
kubectl describe pod nginx-deployment-7c79c4bf97-zgn6f
# 强制删除 Terminating Pods：
kubectl delete pod nginx-deployment-7c79c4bf97-xsvnj --grace-period=0 --force
kubectl delete pod nginx-deployment-7c79c4bf97-zgn6f --grace-period=0 --force

kubectl get nodes
kubectl describe node <node-name>
kubectl get pods -n kube-system
journalctl -u kubelet -f

kubectl version

kubectl port-forward svc/nginx-service 8080:80

# 使用ingress暴露端口

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl get pods -n ingress-nginx





apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl get pods

apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
kubectl apply -f nginx-service.yaml
kubectl get service nginx-service
sudo firewall-cmd --zone=public --permanent --add-port=31132/tcp
sudo firewall-cmd --reload

```

## 版本升级

```bash
# 升级控制平面
sudo dnf update && sudo dnf install -y kubeadm=1.30.x-00
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.30.x
sudo dnf update && sudo dnf install -y kubelet=1.30.x-00 kubectl=1.30.x-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet
# 升级工作节点
sudo dnf update && sudo dnf install -y kubeadm=1.30.x-00 kubelet=1.30.x-00 kubectl=1.30.x-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# 验证版本
kubectl get nodes
kubectl version
kubectl get pods --all-namespaces


```

## ports

Port(s)	|Description
---|---
6443	|Kubernetes API server
2379-2380	|etcd server client API
10250	|Kubelet API
10251	|kube-scheduler
10252	|kube-controller-manager
10255	|Read-only Kubelet API
5473	|ClusterControlPlaneConfig API


