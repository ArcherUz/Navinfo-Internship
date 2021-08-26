# Kubernetes 是什么？

> Kubernetes 是一个可移植的、可扩展的开源平台，用于管理容器化的工作负载和服务，可促进声明式配置和自动化。

```python
什么是声明式？
例如我们有一个用户列表，用 python 查找手机号为 183 开头的用户
def get_users(users):
    ret = []
    for user in users:
        if user['phone'].startswith('183'):
            ret.append(user)
    return ret
这是命令式的作法，给出通向目标的每个指令
```



```sql
而声明式语言则直接描述目标
SELECT * FROM users where phone like '183%';
声明式使用方便、容易理解、易于优化，但表达能力有限
```

Kubernetes管理运行应用程序的容器，提供了一个可弹性运行分布式系统的框架。Kubernetes 会满足你的扩展要求、故障转移、部署模式等。

Kubernetes 可以帮助您在不同环境中大规模交付和管理容器化应用、传统应用和云原生应用，以及重构成微服务的应用。

Kubernetes提供：

1. **服务发现和负载均衡**

   如果进入容器的流量很大， Kubernetes 可以负载均衡并分配网络流量，从而使部署稳定。

2. **存储编排**

   Kubernetes 允许你自动挂载你选择的存储系统，例如本地存储、公共云提供商等。

3. **自动部署和回滚**

   可以使用 Kubernetes 描述已部署容器的所需状态，它以受控的速率将实际状态 更改为期望状态。例如，你可以自动化 Kubernetes 来为你的部署创建新容器， 删除现有容器并将它们的所有资源用于新容器。

4. **自动完成装箱计算**

   Kubernetes 允许你指定每个容器所需 CPU 和内存（RAM）。

5. **自我修复**

   Kubernetes 重新启动失败的容器、替换容器、杀死不响应用户定义的 运行状况检查的容器。

6. **密钥与配置管理**

   Kubernetes 允许你存储和管理敏感信息，例如密码、OAuth 令牌和 ssh 密钥。 你可以在不重建容器镜像的情况下部署和更新密钥和应用程序配置，也无需在堆栈配置中暴露密钥。

Kubernetes 不是 PaaS（平台即服务）系统。由于 Kubernetes 在容器级别而不是在硬件级别运行，它提供了 PaaS 产品共有的一些普遍适用的功能， 例如部署、扩展、负载均衡、日志记录和监视。 但是，Kubernetes 不是单体系统。

1. Kubernetes不限制支持的应用程序类型。
2. 不部署源代码，也不构建你的应用程序。
3. 不提供应用程序级别的服务作为内置服务，如消息中间件，数据库。
4. 不提供也不采用任何全面的机器配置、维护、管理。

Kubernetes 集群是一组用于运行容器化应用的节点计算机。Kubernetes 集群可视化为两个部分：控制平面与计算设备（或称为节点）。每个节点都是其自己的 [Linux®](https://www.redhat.com/zh/topics/linux/what-is-linux) 环境，可以是物理机也可以是虚拟机。每个节点都运行由若干容器组成的容器集。

## **为什么需要Kubernetes**?

真正的生产型应用会涉及多个容器。这些容器必须跨多个服务器主机进行部署。容器安全性需要多层部署，因此可能会比较复杂。但 Kubernetes 有助于解决这一问题。Kubernetes 可以提供所需的编排和管理功能，以便您针对这些工作负载大规模部署容器。借助 Kubernetes 编排功能，您可以构建跨多个容器的应用服务、跨集群调度、扩展这些容器，并长期持续管理这些容器的健康状况。

# K8s原理

控制器（Controller）主动管理 Kubernetes 对象的状态，并会作出变更，使集群从当前状态转变为预期状态。 

开发人员或系统管理员利用提交到 Kubernetes API 的 YAML 或 JSON 文件来指定定义的状态。Kubernetes 使用控制器来分析新定义的状态和集群中实际状态之间的差别。

集群的预期状态定义了应运行哪些应用或其他工作负载、应使用哪些容器镜像、应提供哪些资源，以及其他配置详情。

配置数据以及有关集群状态的信息位于 etcd。

假设您要部署一个预期状态为“3”的应用，这意味着要运行该应用的 3 个副本。如果这些容器中有 1 个发生崩溃，Kubernetes 副本集就会看到只有 2 个副本在运行，所以它会再添加 1 个副本以满足预期状态。

Kubernetes 部署是管理副本集的首选方式，可以向容器集提供声明性更新，因此您不必自己来手动管理它们。 

# Kubernetes组件

节点（Node）负责执行由控制平面分配的请求任务。

容器集（Pod）部署到单个节点上且包含一个或多个容器的容器组。容器集是最小、最简单的 Kubernetes 对象。



Pod与Pod之间通过内部的ip address来交联。但是，Pod在k8s里是较为脆弱的。比如容器里的应用程序崩溃了，或者工作节点用光了资源，Pod就会关闭。随后k8s会创建一个新的pod来代替之前出错的pod。这时，k8s会重新分配一个新的ip address。

每次都去重新分配ip是不方便的，所以k8s组件里有服务(Service)。这个服务更像是一个静态的，永久的ip地址，赋予在每个容器集上。服务和容器集的生命周期并不共享。



mongo-db是app链接数据库的接口，如果mongo-db改变了，需要改变应用程序连接到原mongo-db的url，重新部署应用程序，存放到云端，再拉取到pod。



ConfigMap是pod外部配置，我们只需要更改configmap的值。ConfigMap可储存加密后的用户名和密码。

如果数据库再pod中崩溃了，其中的数据会丢失。

*k8s并不负责备份数据，仅提供备份数据的接口。



服务（service）除了分配永久ip地址，还负责负载平衡。当一个运行节点的app崩溃掉，备份的app可以通过Service立即启用。但实际上，并不需要一个一个重新部署pod再作为备份，只需要部署Deployment。Deployment是pod的抽象形式，pod会根据deployment来配置备份。

*数据库(database)也需要备份，但是并不能通过deployment部署。StatefulSet才能处理数据库之间的同步等问题。



# Kubernetes构架



一个 Kubernetes 集群由一组被称作节点的机器组成。这些节点上运行 Kubernetes 所管理的容器化应用。集群具有至少一个工作节点。



kubeadm init --apiserver-advertise-address=xxx.xxx.xx.xxx --service-cidr=192.1.0.0/16 --pod-network-cidr=192.244.0.0/16

--service-cidr=192.1.0.0/16 指定service 的IP 范围

--pod-network-cidr=192.244.0.0/16 指定 pod 的网络， control plane 会自动将 网络发布到其他节点的node，让其上启动的容器使用此网络

## 控制平面组件

控制平面的组件对集群做出全局决策(比如调度)，以及检测和响应集群事件。

1. ### kube-apiserver 

   API 服务器是 Kubernetes 控制面的组件， 该组件公开了 Kubernetes API。 API 服务器是 Kubernetes 控制面的前端。它暴露API的接口来定义、部署和管理容器的生命周期。

   设置 apiserver 绑定的 IP。工作节点通过绑定的ip连接到主节点。

   负责接收请求，验证请求身份组，发送请求到pod。

2. **kube-scheduler**

   负责监视新创建的、未指定运行节点（node）的 Pods，选择节点让 Pod 在上面运行。

   调度决策考虑的因素包括单个 Pod 和 Pod 集合的资源需求、硬件/软件/策略约束、亲和性和反亲和性规范、数据位置、工作负载间的干扰和最后时限。

   当想要创建一个新的pod，apiserver会首先接受到请求，再发送到scheduler，它将决定将pod部署到哪个节点。真正运行pod是由kubelet负责

3. ### kube-controller-manager

   运行控制器进程。控制器通过apiserver监控集群的公共状态，致力于将当前状态转变为期望的状态。

   控制器包括：

   节点控制器：负责在节点出现故障时进行通知和响应

   任务控制器：监测代表一次性任务的 Job 对象，然后创建 Pods 来运行这些任务直至完成

   服务帐户和令牌控制器：为新的命名空间创建默认帐户和 API 访问令牌

   Controller-manager发现异常pod后，将请求发送到Scheduler，由Scheduler根据节点资源，决定哪个pod应被重启，将请求再发送到kubelet重启。

4. ### etcd

   etcd 是兼具一致性和高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库。

   配置数据以及有关集群状态的信息位于 etcd（一个键值存储数据库）中。etcd 采用分布式、容错设计，被视为集群的最终事实来源。

   ### Scheduler通过etcd得知资源信息，Controller-manager通过etcd得知pod状态。*应用程序的数据并不存在发etcd

   ## Node组件

   1. ### kubelet

      一个在集群中每个节点（node）上运行的代理。 它保证容器（containers）都 运行在 Pod 中。

   2. ### kube-proxy

      kube-proxy 是集群中每个节点上运行的网络代理， 实现 Kubernetes 服务（Service） 概念的一部分。



# Kube admin和Rancher Kubernetes Engine(RKE)

安装Kubernetes是公认的对运维和DevOps而言最棘手的问题之一。因为Kubernetes可以在各种平台和操作系统上运行，所以在安装过程中需要考虑很多因素。基础安装环境在k8s-env.sh。

## Kubeadm

> Kubeadm 是一个提供了 `kubeadm init` 和 `kubeadm join` 的工具， 作为创建 Kubernetes 集群的 “快捷途径” 的最佳实践。

kubeadm init --apiserver-advertise-address=xxx.xxx.xx.xxx --service-cidr=192.1.0.0/16 --pod-network-cidr=192.244.0.0/16

Kubeadm init拉取所需组件镜像，搭建控制平面节点。Kubeadm join 用于搭建工作节点并将其加入到集群中。

国内防火墙不支持访问k8s.gcr.io，所以只能手动在镜像网站拉取本地镜像到docker，并修改镜像的tag。

kubeadm init --apiserver-advertise-address=xxx.xxx.xx.xxx --service-cidr=192.1.0.0/16 --pod-network-cidr=192.244.0.0/16

成功后生成Kubeadm token，使用kubeadm join复制在工作节点即可。



