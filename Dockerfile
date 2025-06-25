FROM ubuntu:20.04
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# install strongswan
#   deps
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
                --enable-save-keys \
 && make -j"$(nproc)" \
 && make install

# install liboqs
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#     git cmake ninja-build libssl-dev pkg-config
# RUN git clone -b main https://github.com/open-quantum-safe/liboqs.git /opt/liboqs
# RUN mkdir /opt/liboqs/build && cd /opt/liboqs/build && \
#     cmake -GNinja \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DBUILD_SHARED_LIBS=ON \
#       -DCMAKE_INSTALL_PREFIX=/usr .. && \
#     ninja && ninja install && ldconfig

# ipsec port
EXPOSE 500/udp 4500/udp

# entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露 IKEv2/UDP 端口
EXPOSE 500/udp 4500/udp

ENTRYPOINT ["entrypoint.sh"]
