# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Paul Nilsson, paul.nilsson@cern.ch, 2023
#
# Dockerfile for building a PanDA Pilot image using Dask and ROOT, based on AlmaLinux9
# using default system Python version (3.9.16)
# The PanDA Pilot is git installed and placed into the same folder as this Dockerfile.
# (execute 'git clone https://github.com/PanDAWMS/pilot3.git' in this folder for the official and current version).
#
# Build with (e.g.):
# docker build -t dask-pilot . --build-arg RUCIO_VERSION=1.31.5 --build-arg DASK_VERSION=2023.4.1

FROM almalinux/9-base

# build arguments
ARG RUCIO_VERSION
ARG DASK_VERSION

# environment variables for the pilot and rucio
ENV PILOT_WORKFLOW generic
ENV PILOT_JOB_LABEL user
ENV PILOT_QUEUE GOOGLE_DASK
ENV PILOT_USER atlas
ENV PILOT_PANDA_SERVER https://pandaserver.cern.ch
ENV PILOT_LIFETIME 86500
ENV PILOT_LEASETIME 86400
ENV PILOT_WORKDIR /
ENV PILOT_SOURCE_DIR /usr/local/lib/python3.9/site-packages
ENV HARVESTER_PILOT_CONFIG /
ENV X509_CERT_DIR /
ENV X509_USER_PROXY /
ENV RUCIO_ACCOUNT pilot
ENV RUCIO_AUTH_TYPE x509_proxy
ENV RUCIO_LOCAL_SITE_ID GOOGLE-EU_SCRATCHDISK
ENV PYTHON_VERSION python3.9
ENV RUCIO_PYTHONBIN python3.9
ENV ROOT_VERSION root-core-6.28.04-1.el9.x86_64

MAINTAINER Paul Nilsson

RUN mkdir /opt/app

# prepare for yum installations
RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum

# prepare for rucio installation
RUN rpm -i https://repo.almalinux.org/almalinux/9/CRB/x86_64/os/Packages/libdb-cxx-5.3.28-53.el9.x86_64.rpm
RUN yum install -y yum-utils gcc voms-clients-java gfal2-all gfal2-util python3-gfal2 xrootd-client \
                   openssl-devel bzip2-devel libffi-devel \
                   nordugrid-arc-plugins-needed \
                   nordugrid-arc-client nordugrid-arc-plugins-gfal \
                   nordugrid-arc-plugins-globus nordugrid-arc-plugins-s3 \
                   nordugrid-arc-plugins-xrootd \
                   $ROOT_VERSION python3-root python3-pip git && \
    yum clean all && \
    rm -rf /var/cache/yum

# pip installations
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir --pre rucio-clients[argcomplete]==$RUCIO_VERSION
RUN pip3 install --no-cache-dir jinja2 j2cli pyyaml requests uproot

# install dask
RUN pip3 install --no-cache-dir "dask[complete]==$DASK_VERSION"
RUN pip3 install --no-cache-dir dask-awkward dask-histogram coffea

# Add a separate user and change ownership of config dir to that user
RUN groupadd -g 1007 zp && \
    useradd -ms /bin/bash -u 1006 -g 1007 atlpan && \
    mkdir -p /opt/rucio/etc/ && \
    chown -R atlpan.zp /opt/rucio/etc/ && \
    mkdir -p /opt/user && \
    chown atlpan.zp /opt/user && \
    mkdir -p /opt/panda && \
    chown -R atlpan.zp /opt/panda

# Download PanDA Pilot
RUN git clone https://github.com/PalNilsson/pilot3.git && \
    mv pilot3 /opt/panda && \
    cd /opt/panda/pilot3 && \
    git checkout next

# copy the pilot source
RUN chown atlpan:zp /opt/panda/pilot3/
RUN cp -r /opt/panda/pilot3/ /usr/local/lib/$PYTHON_VERSION/site-packages/.

USER atlpan
WORKDIR /mnt/dask

COPY rucio.cfg /opt/rucio/etc/rucio.cfg
COPY execute.sh /usr/bin/execute.sh

ENV PATH $PATH:/opt/rucio/bin

CMD ["/bin/bash", "/usr/bin/execute.sh"]

