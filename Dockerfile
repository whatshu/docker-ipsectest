FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# install liboqs
#   deps
RUN apt-get update && \
    apt-get install -y \
    astyle cmake gcc ninja-build libssl-dev \
    python3-pytest python3-pytest-xdist unzip \
    xsltproc doxygen graphviz python3-yaml valgrind \
    git
#   install
WORKDIR /opt
RUN git clone -b main https://github.com/open-quantum-safe/liboqs.git /opt/liboqs
RUN mkdir /opt/liboqs/build && cd /opt/liboqs/build && \
    cmake -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_INSTALL_PREFIX=/usr .. && \
    ninja
# RUN cd /opt/liboqs/build && ninja run_tests
RUN cd /opt/liboqs/build && ninja install && ldconfig

# install strongswan
#   deps
RUN apt-get update && apt-get install -y \
    wget build-essential pkg-config \
    libgmp-dev libssl-dev libcap-ng-dev libcurl4-openssl-dev \
    iproute2 iptables iputils-ping ca-certificates tcpdump \
  && rm -rf /var/lib/apt/lists/*
#   install
ENV PATH="/usr/sbin:${PATH}"
WORKDIR /opt
RUN wget https://download.strongswan.org/strongswan-6.0.1.tar.bz2
RUN tar xjf strongswan-6.0.1.tar.bz2 \
 && cd strongswan-6.0.1 \
 && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
                --enable-swanctl --enable-openssl --enable-eap-mschapv2 \
                --enable-save-keys --enable-ml --enable-oqs \
 && make -j"$(nproc)" \
 && make install

# ipsec port
EXPOSE 500/udp 4500/udp

# entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
