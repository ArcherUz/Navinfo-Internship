

```bash
#!/bin/bash
#=================centos virtual machine first depoly setup======================
yum install -y wget
#repo backup
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#new repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all && yum makecache
#basic dependency
yum install -y yum-utils device-mapper-persistent-data lvm2
#docker-ce repo
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
```

