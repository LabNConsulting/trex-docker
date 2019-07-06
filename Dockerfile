FROM ubuntu:18.04

RUN apt-get update -qy && apt-get upgrade -y && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bash bash-completion bsdtar cpio curl \
        git iproute2 iputils-ping gettext locales make net-tools \
        netcat-openbsd sudo tidy libffi-dev libssl-dev zlib1g-dev \
        libgmp-dev zlib1g-dev libedit-dev \
        git libtool linux-headers-generic \
        libpython-dev libssl-dev bzip2 gettext \
        libncurses5-dev patch perl-modules \
        util-linux wget xsltproc zlib1g-dev xutils-dev \
        python python-dev python-ipaddr python-pip \
        python3 python3-dev python3-pip python3-venv && \
        echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
        locale-gen && \
    python3 -m pip install -U coverage cryptography lxml nose pylint \
        pytest pyyaml ryu tox twine wheel \
        dpkt jsonrpclib-pelix pyyaml pyzmq-ctypes repoze.lru scapy simple_enum simpy texttable && \
    python2 -m pip install -U coverage cryptography lxml nose pylint \
        pytest pyyaml ryu tox twine wheel \
        dpkt jsonrpclib-pelix pyyaml pyzmq-ctypes repoze.lru scapy simple_enum simpy texttable

ARG TREX_TAG=v2.57
ADD https://trex-tgn.cisco.com/trex/release/${TREX_TAG}.tar.gz trex.tar.gz
RUN tar -xf trex.tar.gz && mv ${TREX_TAG} /trex && rm trex.tar.gz
WORKDIR /trex

RUN tar -xf trex_client*.tar.gz && \
    cp -pr trex_client/interactive/trex_stl_lib /usr/local/lib/python2.7/site-packages && \
    cp -pr trex_client/stf/trex_stf_lib /usr/local/lib/python2.7/site-packages && \
    cp -pr trex_client/external_libs/trex-openssl /usr/local/lib/python2.7/site-packages && \
    cp -pr trex_client/interactive/trex_stl_lib /usr/local/lib/python3.6/site-packages && \
    cp -pr trex_client/stf/trex_stf_lib /usr/local/lib/python3.6/site-packages && \
    cp -pr trex_client/external_libs/trex-openssl /usr/local/lib/python3.6/site-packages && \
    mkdir -p /usr/local/lib/python3.7/site-packages && \
    cp -pr trex_client/interactive/trex_stl_lib /usr/local/lib/python3.7/site-packages && \
    cp -pr trex_client/stf/trex_stf_lib /usr/local/lib/python3.7/site-packages && \
    cp -pr trex_client/external_libs/trex-openssl /usr/local/lib/python3.7/site-packages && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
