FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# 安装编译 StrongSwan 的依赖，以及运行时工具
RUN apt-get update && apt-get install -y \
    wget build-essential pkg-config \
    libgmp-dev libssl-dev libcap-ng-dev libcurl4-openssl-dev \
    iproute2 iptables iputils-ping ca-certificates tcpdump \
  && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/sbin:${PATH}"

WORKDIR /opt
# 下载并编译 StrongSwan 6.0.1
RUN wget https://download.strongswan.org/strongswan-6.0.1.tar.bz2 \
 && tar xjf strongswan-6.0.1.tar.bz2 \
 && cd strongswan-6.0.1 \
 && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
                --enable-swanctl --enable-openssl --enable-eap-mschapv2 \
 && make -j"$(nproc)" \
 && make install

# Clean up source files
# RUN cd /opt \
#  && rm -rf strongswan-6.0.1

# 复制通用的启动脚本
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露 IKEv2/UDP 端口
EXPOSE 500/udp 4500/udp

ENTRYPOINT ["entrypoint.sh"]
