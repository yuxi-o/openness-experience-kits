# openNESS deployment

openNESS���������ַ�ʽ��Network Edge��On-Premise��

openNESSҪ��ֻ��һ̨controller�������ж�̨nodes��

openNESS-191201�汾��Ҫ�����������̻�ֿ⣺

- [openness-experience-kits](https://github.com/open-ness/openness-experience-kits.git)��ansible���̣�����openNESS�����岿��openNESS����ansible������
- [edgecontroller](https://github.com/open-ness/edgecontroller.git)���������ֿ⣬һ��openNESS������ֻ��һ��controller��
- [edgenode](https://github.com/open-ness/edgenode.git)��node�ֿ⣬һ��openNESS�����пɰ������node�ڵ㡣

## 0. Preconditions

������On-premise����Network Edge�����������߲��������߲��𣬶�Ӧ�����²�����������������controller��nodes����

1. ��װCentOS 7.6 Minimal distro (x86_64)��ͳһ����root�û��������룬������NTPʱ��ͬ����

2. ���ð�����yum�ֿ��Լӿ������ٶȡ�
```
cd /etc/yum.repos.d && curl -o CentOS-Base.repo "http://mirrors.aliyun.com/repo/Centos-7.repo"
```

3. ����pip���٣���� ~/.pip/pip.conf �ļ����������£�
```
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
timeout = 6000
[install]
trusted-host = mirrors.aliyun.com
```

4. ����golang������/etc/profile���������´����source��
```
export GO111MODULE=on
export GOPROXY="https://goproxy.cn"
```

5. �޸���������/etc/hostname������ֹ����localhost��localdomain�ַ�����������������Ψһ��controller��nodes�����ֲ����ظ�����
ͬʱӦ����������/etc/hosts:
```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 YOUR_NEW_HOSTNAME
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 YOUR_NEW_HOSTNAME
```
**ע��Ϊʹ��������Ч��Ӧ����������**

6. ����ssh���ܵ�¼��**������controller��ansibleִ��������nodes��������Ҫ**����ִ������������ñ������ܵ�¼��
```
ssh-keygen
ssh-copy-id root@localhost
```

�����������������ʹ��������������ܵ�¼����������
```
ssh-copy-id root@ip
```

## 1. on-premise deployment

on-premise�����ֲ���ʽ�����ߺ����ߣ�offline����

### 1.1 inline-deployment

���߲���ο���[controller-edge-node-setup.md](https://github.com/open-ness/specs/blob/master/doc/getting-started/on-premises/controller-edge-node-setup.md)��

�ɰ����²������ò���openNESS��

1. ��¡�޸Ĺ��ĲֿⲢ��ѹ��
```
git clone https://github.com/yuxi-o/openness-experience-kits.git
cd openness-experience-kits/
git checkout -b flex191201 origin/flex191201
```
**ע������ʵ�ʲ���������޸������ļ�inventory.ini��controller��node��������IP���˺ŵȡ�**

2. cleanup
```
./cleanup_onprem.sh
```

3. ����controller��
controller����kits������ͬһ�������������������
```
./deploy_onprem_controller.sh
```

4. ����node��
node�������preconditios�������controller�����������������node�ڵ㣺
```
./deploy_onprem_node.sh
```

### 1.2 offline-deployment

���߲���ο���[offline-deployment.md](https://github.com/open-ness/specs/blob/master/doc/getting-started/on-premises/offline-deployment.md)��

1. ��¡�޸Ĺ��ĲֿⲢ��ѹ��
```
git clone https://github.com/yuxi-o/openness-experience-kits.git
cd openness-experience-kits/
git checkout -b flex191201 origin/flex191201
```

2. ��ȡ���߰�װ����
```
./prepare_offline_package.sh 
```

����ִ��ʱ�䳤���ޱ���Ļ���/opt/openness-offline/ offline-openness.tarΪ���ɵ����߰�װ����
�����߰�װ�������ڲ���controller��nodes�����ظ�ʹ�á�

3. ����controller��
�������߲����offline-openness.tar��controller�����������ݲ���滮����������inventory.ini��
```
tar xf offline-openness.tar ����ѹ��extract.sh��ansible.tar��openness-experience-kits.tar.gz��offline-controller.tar.gz��offline-node.tar.gz
./extract.sh
cd openness-experience-kits
```

���ݲ���滮���޸�inventory.ini����ȷ��controller������ssh��node������Ȼ���������������controller��
```
./deploy_onprem_controller.sh
```

4. ����node��
node�������preconditios�������controller�����������������node�ڵ㣺
```
./deploy_onprem_node.sh
```

## 2. Network Edge deployment

Network EdgeĿǰ�ٷ���֧�����߰�װ��

### 2.1 inline-deployment

���߲���ο���[controller-edge-node-setup.md](https://github.com/open-ness/specs/blob/master/doc/getting-started/network-edge/controller-edge-node-setup.md)��

�ɰ����²������ò���openNESS��

1. ��¡�޸Ĺ��ĲֿⲢ��ѹ��
```
git clone https://github.com/yuxi-o/openness-experience-kits.git
cd openness-experience-kits/
git checkout -b flex191201 origin/flex191201
```
**ע������ʵ�ʲ���������޸������ļ�inventory.ini��controller��node��������IP���˺ŵȡ�**

2. cleanup
```
./cleanup_ne.sh
```

3. ����controller��
```
./deploy_ne_controller.sh
```

4. ����node��
node�������preconditios�������controller�����������������node�ڵ㣺
```
./deploy_ne_node.sh
```

5. ����dashboard��

��controller�����������������dashboardӦ�ã�
```
docker pull kubernetesui/metrics-scraper:v1.0.1
docker pull kubernetesui/dashboard:v2.0.0-beta4
cd flex/k8s
kubectl apply -f recommended.yaml
kubectl apply -f dashboard-admin-user.yaml
```

�������������ȡdashboard�˿ڣ�recommended.yaml�����ã����޸ģ���Ĭ��30000��
```
kubectl -n kubernetes-dashboard get service kubernetes-dashboard
```

���ˣ���ͨ���������ַ`https://<controller-ip>:<port>/`����dashboard���Ƽ�ʹ�û���������
�������������ȡ��token�������Ȼ���½���ɡ�
```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

