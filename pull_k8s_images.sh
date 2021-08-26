```bash
#!/bin/bash
#===============1st version ========================
#due to the government internet wall, some images can't be pulled correctly
#pull from other sources
#this version of pull-images uses the newest version of images.
for i in `kubeadm config images list`; do 
  imageName=${i#k8s.gcr.io/}
  docker pull registry.aliyuncs.com/google_containers/$imageName
  docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.aliyuncs.com/google_containers/$imageName
done;


#==================2nd version ======================
#you can specify image versions

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


