FROM alpine:3.18

# 1. 安装编译依赖和 tcpdump
RUN apk add --no-cache \
      build-base autoconf automake libtool \
      openssl-dev gmp-dev libcap-ng-dev curl-dev libnl3-dev pkgconf wget \
      iproute2 tcpdump bash

WORKDIR /usr/src

# 2. 下载并解压 StrongSwan 源码
RUN wget https://download.strongswan.org/strongswan-6.0.1.tar.gz \
 && tar xzf strongswan-6.0.1.tar.gz \
 && rm strongswan-6.0.1.tar.gz

WORKDIR strongswan-6.0.1

# 3. 配置编译，指定安装到 /usr 下，保证 sbin 在标准路径
RUN ./configure \
      --enable-openssl \
      --enable-gmp \
      --enable-mlkem \
      --prefix=/usr \
      --sysconfdir=/etc \
      --sbindir=/usr/sbin \
      --libdir=/usr/lib

# 4. 编译并安装
RUN make -j"$(nproc)" && make install

# 5. 确保 /usr/sbin 在 PATH 中（默认 root 环境通常已包含，但显式声明更保险）
ENV PATH="/usr/sbin:/usr/local/sbin:${PATH}"

# 6. 声明配置卷
VOLUME ["/etc/ipsec.d"]

# 7. 启动 strongSwan，不后台化
# ENTRYPOINT ["ipsec", "start", "--nofork"]
ENTRYPOINT ["/bin/sh", "-c", "echo 'ipsec 可执行文件位于：' \"$(which ipsec)\"; exec /bin/sh"]
