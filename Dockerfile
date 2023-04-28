FROM centos:7

# Build arguments
# Tags for rucio and pilot versions (add --build-arg RUCIO_VERSION=1.30.5 --build-arg PILOT_VERSION=3.4.8.5 (e.g.) to docker build command)
ARG RUCIO_VERSION
# NOTE: the pilot is currently not pip installed - the source is assumed to exists in the build area
ARG PILOT_VERSION

# User environment variables to run the pilot
ENV PILOT_WORKFLOW stager
ENV PILOT_JOB_LABEL user
ENV PILOT_QUEUE GOOGLE_DASK
ENV PILOT_USER atlas
ENV PILOT_PANDA_SERVER https://pandaserver.cern.ch
ENV PILOT_LIFETIME 200
ENV PILOT_WORKDIR /
ENV PILOT_SOURCE_DIR /usr/local/lib/python3.6/site-packages/pilot3
ENV HARVESTER_PILOT_CONFIG /
ENV X509_CERT_DIR /
ENV X509_USER_PROXY /
ENV RUCIO_ACCOUNT pilot
ENV RUCIO_AUTH_TYPE x509_proxy
ENV RUCIO_LOCAL_SITE_ID GOOGLE-EU_SCRATCHDISK
#ENV RUCIO_HOME /
#ENV RUCIO_PYTHONBIN python3
#ENV RUCIO_PYTHONBINPATH /

MAINTAINER Paul Nilsson

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum -y install https://repo.ius.io/ius-release-el7.rpm && \
    yum install -y python36u-pip voms-clients-java gfal2-all gfal2-util python3-gfal2 xrootd-client \
                   unzip which \
                   nordugrid-arc-client nordugrid-arc-plugins-gfal \
                   nordugrid-arc-plugins-globus nordugrid-arc-plugins-s3 \
                   nordugrid-arc-plugins-xrootd && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY execute.sh /usr/bin/execute.sh

# Upgrade pip & setuptools and install Rucio
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir --upgrade setuptools && \
    python3 -m pip install --no-cache-dir --pre rucio-clients[argcomplete]==$RUCIO_VERSION && \
    python3 -m pip install --no-cache-dir jinja2 j2cli pyyaml && \
    python3 -m pip install "dask[complete]" #&& \
#    python3 -m pip install dask distributed --upgrade

#RUN mkdir -p /usr/local/lib/python3.6/site-packages/pilot3
#RUN python3 -m pip install --no-cache-dir panda-pilot[argcomplete]==$PILOT_VERSION

# Add a separate user and change ownership of config dir to that user
RUN groupadd -g 1007 zp && \
    useradd -ms /bin/bash -u 1006 -g 1007 atlpan && \
    mkdir -p /opt/rucio/etc/ && \
    chown -R atlpan.zp /opt/rucio/etc/ && \
    mkdir -p /opt/user && \
    chown atlpan.zp /opt/user

# copy the pilot source
COPY --chown=atlpan:zp pilot3/ /usr/local/lib/python3.6/site-packages/pilot3/.
#RUN mkdir /opt/pilot

USER atlpan
WORKDIR /mnt/dask

# Add the configuration template and enable bash completion for the rucio clients
#ADD --chown=user:user rucio.cfg.j2 /opt/user/rucio.cfg.j2
#ADD init_rucio.sh /etc/profile.d/rucio_init.sh

COPY rucio.cfg /opt/rucio/etc/rucio.cfg

ENV PATH $PATH:/opt/rucio/bin

CMD ["/bin/bash", "/usr/bin/execute.sh"]
