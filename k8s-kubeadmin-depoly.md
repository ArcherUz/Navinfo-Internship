# K8S kubeadm 多节点部署

准备两台及以上的虚拟机，2核cpu和2G内存以上

所有节点安装docker-ce 添加docker-ce源，再安装docker-ce

```bash
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl enable docker && systemctl start docker
```

同步时间 

```
yum install -y ntpdate ntpdate aisa.pool.ntp.org
```

确保依赖环境

```
yum install -y yum-utils device-mapper-persistent-data lvm2
```

安装kubelet 和kubeadm以及kubectl 

```
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

k8s-env.sh配置基础环境 **会关闭防火墙

```
#k8s-en.sh

#禁用防火墙
systemctl disable firewalld
systemctl stop firewalld

#关闭selinux
setenforce 0
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#swap会影响性能，关闭swap
swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab

#解决iptables而导致流量无法正确路由的问题
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#设置k8s repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

sysctl --system
```

运行pull-k8s-images.sh拉取镜像

```
set -o errexit
set -o nounset
set -o pipefail

KUBE_VERSION=v1.21.3-rc.0
KUBE_PAUSE_VERSION=3.4.1
ETCD_VERSION=3.4.13-0
DNS_VERSION=1.8.0

GCR_URL=k8s.gcr.io

DOCKERHUB_URL=k8smx

images=(
kube-proxy:${KUBE_VERSION}
kube-scheduler:${KUBE_VERSION}
kube-controller-manager:${KUBE_VERSION}
kube-apiserver:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd:${ETCD_VERSION}
)

for imageName in ${images[@]} ; do
  docker pull $DOCKERHUB_URL/$imageName
  docker tag $DOCKERHUB_URL/$imageName $GCR_URL/$imageName
  docker rmi -f $DOCKERHUB_URL/$imageName
done

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.8.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.8.0 k8s.gcr.io/coredns/coredns:v1.8.0
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.8.0
```

<img src="C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210810163159558.png" alt="image-20210810163159558" style="zoom:50%;" />

kubeadm安装，--pod-network-cidr是为了部署flannel网络做准备

```
kubeadm init --pod-network-cidr=10.244.0.0/16
```

完成后应显示

![image-20210810163636047](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210810163636047.png)

按提示操作

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

增加权限

```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

配置flannel网络，连通从节点与主节点

```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
--no-check-certificate
kubectl apply -f kube-flannel.yml
```

所有节点更改hostname，不能使用localhost

主节点：

```
hostnamectl set-hostname centos-master
在/etc/hosts下添加各节点ip
vim /etc/hosts
192.168.56.102 centos-master
192.168.56.105 centos-node1
192.168.56.109 centos-node2
```

从节点类似

子节点机器安装docker-ce，kubectl，kubeadm，kubelet

在子节点输入主节点返回的kubeadm join

将主节点中的【/etc/kubernetes/admin.conf】文件拷贝到从节点相同目录下，然后配置环境变量

```
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source ~/.bash_profile
```

从节点下载pause镜像，处理从节点的flannel运行

```
docker pull registry.aliyuncs.com/google_containers/pause:3.4.1
docker tag registry.aliyuncs.com/google_containers/pause:3.4.1 k8s.gcr.io/pause:3.4.1
docker rmi registry.aliyuncs.com/google_containers/pause:3.4.1
```

下载kube-proxy镜像

```
docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.21.3
docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.21.3
k8s.gcr.io/kube-proxy:v1.21.3
docker rmi registry.aliyuncs.com/google_containers/kube-proxy:v1.21.3
```

kubectl get pods -n kube-system查看系统服务运行情况







