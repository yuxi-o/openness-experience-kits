# openNESS deployment

openNESS部署有两种方式：Network Edge和On-Premise。

openNESS要求只有一台controller，可以有多台nodes。

openNESS-191201版本主要包含三个工程或仓库：

- [openness-experience-kits](https://github.com/open-ness/openness-experience-kits.git)：ansible工程，负责openNESS的总体部署，openNESS采用ansible管理部署。
- [edgecontroller](https://github.com/open-ness/edgecontroller.git)：控制器仓库，一个openNESS部署中只有一个controller。
- [edgenode](https://github.com/open-ness/edgenode.git)：node仓库，一个openNESS部署中可包含多个node节点。

## 0. Preconditions

无论是On-premise还是Network Edge部署，无论在线部署还是离线部署，都应按如下步骤配置所有主机（controller和nodes）：

1. 安装CentOS 7.6 Minimal distro (x86_64)，统一配置root用户名和密码，并配置NTP时间同步。

2. 配置阿里云yum仓库以加快下载速度。
```
cd /etc/yum.repos.d && curl -o CentOS-Base.repo "http://mirrors.aliyun.com/repo/Centos-7.repo"
```

3. 配置pip加速，添加 ~/.pip/pip.conf 文件，内容如下：
```
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
timeout = 6000
[install]
trusted-host = mirrors.aliyun.com
```

4. 配置golang代理，在/etc/profile最后加上如下代码后source。
```
export GO111MODULE=on
export GOPROXY="https://goproxy.cn"
```

5. 修改主机名（/etc/hostname），禁止包含localhost和localdomain字符串，主机名需网络唯一（controller和nodes中名字不能重复）。
同时应用主机名到/etc/hosts:
```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 YOUR_NEW_HOSTNAME
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 YOUR_NEW_HOSTNAME
```
**注：为使主机名生效，应重启主机。**

6. 配置ssh免密登录（**适用于controller和ansible执行主机，nodes主机不需要**）。执行如下命令，配置本机免密登录：
```
ssh-keygen
ssh-copy-id root@localhost
```

配置其他相关主机以使相关主机可以免密登录其他主机：
```
ssh-copy-id root@ip
```

## 1. on-premise deployment

on-premise有两种部署方式：在线和离线（offline）。

### 1.1 inline-deployment

在线部署参考：[controller-edge-node-setup.md](https://github.com/open-ness/specs/blob/master/doc/getting-started/on-premises/controller-edge-node-setup.md)。

可按如下步骤配置部署openNESS：

1. 克隆修改过的仓库并解压。
```
git clone https://github.com/yuxi-o/openness-experience-kits.git
cd openness-experience-kits/
git checkout -b flex191201 origin/flex191201
```
**注：根据实际部署情况，修改配置文件inventory.ini的controller和node主机名、IP和账号等。**

2. cleanup
```
./cleanup_onprem.sh
```

3. 部署controller。
controller可与kits运行于同一主机，运行如下命令部署：
```
./deploy_onprem_controller.sh
```

4. 部署node。
node主机完成preconditios步骤后，在controller主机运行如下命令部署node节点：
```
./deploy_onprem_node.sh
```

### 1.2 offline-deployment

离线部署参考：[offline-deployment.md](https://github.com/open-ness/specs/blob/master/doc/getting-started/on-premises/offline-deployment.md)。

1. 克隆修改过的仓库并解压。
```
git clone https://github.com/yuxi-o/openness-experience-kits.git
cd openness-experience-kits/
git checkout -b flex191201 origin/flex191201
```

2. 获取离线安装包。
```
./prepare_offline_package.sh 
```

命令执行时间长，无报错的话，/opt/openness-offline/ offline-openness.tar为生成的离线安装包。
此离线安装包可用于部署controller和nodes，可重复使用。

3. 部署controller。
拷贝离线部署包offline-openness.tar到controller主机，并根据部署规划，合理配置inventory.ini。
```
tar xf offline-openness.tar ；解压出extract.sh，ansible.tar，openness-experience-kits.tar.gz，offline-controller.tar.gz，offline-node.tar.gz
./extract.sh
cd openness-experience-kits
```

根据部署规划，修改inventory.ini，并确保controller可无密ssh到node主机。然后，运行如下命令部署controller：
```
./deploy_onprem_controller.sh
```

4. 部署node。
node主机完成preconditios步骤后，在controller主机运行如下命令部署node节点：
```
./deploy_onprem_node.sh
```

## 2. Network Edge deployment

Network Edge目前官方仅支持在线安装。

### 2.1 inline-deployment

在线部署参考：[controller-edge-node-setup.md](https://github.com/open-ness/specs/blob/master/doc/getting-started/network-edge/controller-edge-node-setup.md)。

可按如下步骤配置部署openNESS：

1. 克隆修改过的仓库并解压。
```
git clone https://github.com/yuxi-o/openness-experience-kits.git
cd openness-experience-kits/
git checkout -b flex191201 origin/flex191201
```
**注：根据实际部署情况，修改配置文件inventory.ini的controller和node主机名、IP和账号等。**

2. cleanup
```
./cleanup_ne.sh
```

3. 部署controller。
```
./deploy_ne_controller.sh
```

4. 部署node。
node主机完成preconditios步骤后，在controller主机运行如下命令部署node节点：
```
./deploy_ne_node.sh
```

5. 部署dashboard。

在controller上运行如下命令，部署dashboard应用：
```
docker pull kubernetesui/metrics-scraper:v1.0.1
docker pull kubernetesui/dashboard:v2.0.0-beta4
cd flex/k8s
kubectl apply -f recommended.yaml
kubectl apply -f dashboard-admin-user.yaml
```

运行如下命令获取dashboard端口（recommended.yaml中配置，可修改），默认30000：
```
kubectl -n kubernetes-dashboard get service kubernetes-dashboard
```

至此，可通过浏览器地址`https://<controller-ip>:<port>/`访问dashboard，推荐使用火狐浏览器。
复制如下命令获取的token到浏览器然后登陆即可。
```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

