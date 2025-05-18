# install-harbor

```bash
# 替换为你的服务器IP
serverIP="1.2.3.4"
# 提前安装好docker环境（含docker-compose）
# 自签名证书制作
mkdir harborcert
cd harborcert
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=MyPersonal Root CA" \
 -key ca.key \
 -out ca.crt
# 这里可以使用域名，本文用IP形式
openssl genrsa -out harbor.key 4096
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal" \
    -key harbor.key \
    -out harbor.csr
openssl x509 -req -sha512 -days 3650 \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in harbor.csr \
    -out harbor.crt
mkdir -p /etc/docker/certs.d/${serverIP}
cp -rp ./* /etc/docker/certs.d/${serverIP}/

# 下载离线包
# https://github.com/goharbor/harbor/releases
# 解压离线包
tar xzvf harbor-offline-installer-version.tgz
# 配置yaml文件
cd harbor
cp harbor.yml.tmpl harbor.yml
vi harbor.yml
# 设置主机IP(或域名参考官网)
# hostname 1.2.3.4
# certificate /etc/docker/certs.d/1.2.3.4/harbor.crt
# private_key /etc/docker/certs.d/1.2.3.4/harbor.key
# harbor_admin_password 你的harboradmin密码
# 默认密码admin  Harbor12345
# 开始安装
./install.sh

# 配置docker信任主机
cat << /etc/docker/daemon.json > EOF
{
  "insecure-registries":["${serverIP}"]
}
EOF
systemctl daemon-reload
systemctl restart docker

# 测试
# push前必须登录
docker login ${serverIP}
docker push ${serverIP}/myproject/myrepo:mytag


# 安装后harbor的管理，需要当时安装的时候，docker-compose文件所在目录
cd harbor
# 关闭
docker compose down -v
# 启动
docker compose up -d
```

## 配置复制

1. 添加仓库。这里以open-webui为例。参数填写如图所示
![image](https://github.com/user-attachments/assets/180f3696-e58d-488b-81e1-b1e47d111709)
2. 复制管理。这里以open-webui为例。参数填写如图所示
![image](https://github.com/user-attachments/assets/2918a6c2-5809-44c7-8c77-2a98d2c14e52)
3. 点击复制。拉取其他公私镜像。
   ![image](https://github.com/user-attachments/assets/1868c4c9-18a8-41c6-9875-e473f0be9422)

