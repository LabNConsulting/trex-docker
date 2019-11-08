FROM ubuntu:18.04
ARG TARFILE=latest

RUN apt-get update -qy && apt-get upgrade -y && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bash bash-completion bsdtar bzip2 cpio curl ethtool gettext gettext \
        git git iproute2 iputils-ping libedit-dev libffi-dev libgmp-dev \
        libncurses5-dev libpython-dev libssl-dev libssl-dev libtool \
        linux-headers-generic locales make net-tools netcat-openbsd \
        patch pciutils perl-modules python python-dev python-ipaddr python-pip \
        python3 python3-dev python3-pip python3-venv sudo tidy util-linux wget \
        xsltproc xutils-dev  zlib1g-dev && \
        echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
        locale-gen && \
    python3 -m pip install -U coverage cryptography lxml nose pylint \
        pytest pyyaml ryu tox twine wheel \
        dpkt jsonrpclib-pelix pyyaml pyzmq-ctypes repoze.lru scapy simple_enum simpy texttable && \
    python2 -m pip install -U coverage cryptography lxml nose pylint \
        pytest pyyaml ryu tox twine wheel \
        dpkt jsonrpclib-pelix pyyaml pyzmq-ctypes repoze.lru scapy simple_enum simpy texttable

COPY wait-for*.sh /usr/bin/
RUN curl https://trex-tgn.cisco.com/trex/release/${TARFILE} | tar -xzf - && mv v?.?? /trex
WORKDIR /trex
RUN tar -xf trex_client*.tar.gz && \
    # silly expectation of trex
    cp -pr trex_client/external_libs /usr/local && \
    # Python2.7
    (cp -pr trex_client/interactive/trex_stl_lib /usr/local/lib/python2.7/dist-packages || \
     cp -pr trex_client/stl/trex_stl_lib /usr/local/lib/python2.7/dist-packages) && \
    cp -pr trex_client/stf/trex_stf_lib /usr/local/lib/python2.7/dist-packages && \
    cp -pr trex_client/external_libs/trex-openssl /usr/local/lib/python2.7/dist-packages && \
    # Python3.6
    (cp -pr trex_client/interactive/trex_stl_lib /usr/local/lib/python3.6/dist-packages || \
     cp -pr trex_client/stl/trex_stl_lib /usr/local/lib/python3.6/dist-packages) && \
    cp -pr trex_client/stf/trex_stf_lib /usr/local/lib/python3.6/dist-packages && \
    cp -pr trex_client/external_libs/trex-openssl /usr/local/lib/python3.6/dist-packages && \
    # Python3.7
    mkdir -p /usr/local/lib/python3.7/dist-packages && \
    (cp -pr trex_client/interactive/trex_stl_lib /usr/local/lib/python3.7/dist-packages || \
     cp -pr trex_client/stl/trex_stl_lib /usr/local/lib/python3.7/dist-packages) && \
    cp -pr trex_client/stf/trex_stf_lib /usr/local/lib/python3.7/dist-packages && \
    cp -pr trex_client/external_libs/trex-openssl /usr/local/lib/python3.7/dist-packages && \
    # Cleanup image
    rm trex_client*.tar.gz && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


EXPOSE 4500 4501 8090
