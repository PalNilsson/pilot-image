FROM centos:7

# Tag for rucio version (add --build-arg TAG=1.30.5 (e.g.) to docker build command)
ARG TAG

MAINTAINER Paul Nilsson

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum -y install https://repo.ius.io/ius-release-el7.rpm && \
    yum install -y python36u-pip voms-clients-java gfal2-all gfal2-util python3-gfal2 xrootd-client \
                   nordugrid-arc-client nordugrid-arc-plugins-gfal \
                   nordugrid-arc-plugins-globus nordugrid-arc-plugins-s3 \
                   nordugrid-arc-plugins-xrootd && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY execute.sh /usr/bin/execute.sh

# Upgrade pip & setuptools and install Rucio
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install  --no-cache-dir --upgrade setuptools && \
    python3 -m pip install --no-cache-dir --pre rucio-clients[argcomplete]==$TAG && \
    python3 -m pip install --no-cache-dir jinja2 j2cli pyyaml


# Add a separate user and change ownership of config dir to that user
RUN groupadd -g 1000 zp && \
    useradd -ms /bin/bash -u 1000 -g 1000 dask && \
    mkdir -p /opt/rucio/etc/ && \
    chown -R dask:zp /opt/rucio/etc/ && \
    mkdir -p /opt/user && \
    chown dask:zp /opt/user

# copy the pilot source
COPY --chown=dask:zp pilot3/ /usr/local/lib/python3.6/site-packages/pilot3/.
RUN mkdir /opt/pilot

USER dask
WORKDIR /home/dask

# Add the configuration template and enable bash completion for the rucio clients
#ADD --chown=user:user rucio.cfg.j2 /opt/user/rucio.cfg.j2
#ADD init_rucio.sh /etc/profile.d/rucio_init.sh

COPY rucio.cfg /opt/rucio/etc/rucio.cfg

ENV PATH $PATH:/opt/rucio/bin

CMD ["/bin/bash", "/usr/bin/execute.sh"]
