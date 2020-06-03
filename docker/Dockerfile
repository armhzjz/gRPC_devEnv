ARG     DIST=debian
ARG     DIST_VERSION=stretch-slim

FROM    ${DIST}:${DIST_VERSION}

############################################################################
# create and set the working directory
############################################################################
RUN     set -x && \
        mkdir -p /data/ && \
        :

WORKDIR /data/

############################################################################
# install dumb-init which will run as PID 1 in the container
# plus install additional packages
############################################################################
RUN     set -x && \
        apt-get update && \
        apt-get install -y \
            dumb-init \
            vim \
            procps \
            man \
            && \
        rm -fr /var/lib/apt/lists/* && \
        :

############################################################################
# set the locale to en_US.UTF-8
############################################################################
RUN     set -x && \
        apt-get update && \
        apt-get install -y \
            locales \
            && \
        rm -fr /var/lib/apt/lists/* && \
        sed -i 's/# en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen && \
        locale-gen && \
        :
ENV     LANG=en_US.UTF-8
ENV     LANGUAGE=en_US:en
ENV     LC_ALL=en_US.UTF-8

############################################################################
#set bash as default shell
############################################################################
RUN     set -x && \
        ln -sf bash /bin/sh && \
        :

############################################################################
# ensure bashrc is called when user uses sh
############################################################################
ENV     ENV=/etc/bash.bashrc
RUN     echo "alias ll='ls -l'" >> ${ENV}
# ensure future docker RUN commands use bash
SHELL   ["/bin/bash", "-c"]

############################################################################
# setup entry point and default command
############################################################################
# dumb-init is PID 1 and runs a script that ensures system-wide environment variables are set
ARG     INIT_SCRIPT=/etc/init.d/docker-entrypoint.sh
RUN     set -x && \
        touch ${INIT_SCRIPT} && \
        chmod a+x ${INIT_SCRIPT} && \
        # including the shebang ensures all shell related environment variables are setup
        echo '#!/bin/bash' >> ${INIT_SCRIPT} && \
        # script just executes whatever command is passed to the container
        echo 'exec "$@"' >> ${INIT_SCRIPT} && \
        :
ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/etc/init.d/docker-entrypoint.sh" ]
CMD ["bash"]

############################################################################
# install grpc prerequisites
############################################################################
RUN     set -x && \
        apt-get update && \
        apt-get install -y \
            build-essential \
            autoconf \
            libtool \
            pkg-config \
            wget \
            git \
            automake \
            curl \
            make \
            g++ \
            unzip \
            tmux \
            && \
        rm -fr /var/lib/apt/lists/* && \
        :

############################################################################
# install cmake version 3.16.1
############################################################################
RUN     set -x && \
        cd /data && \
        mkdir work && cd work && \
        wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.16.1/cmake-3.16.1-Linux-x86_64.sh && \
        sh cmake-linux.sh -- --skip-license --prefix=/usr && \
        rm cmake-linux.sh && \
        :

############################################################################
# install gRPC 1.28.x
############################################################################
RUN     git clone --recurse-submodules -b v1.28.1 https://github.com/grpc/grpc && \
        cd grpc && \
        mkdir -p cmake/build && \
        pushd cmake/build && \
        cmake -DBUILD_SHARED_LIBS=ON \
              -DgRPC_BUILD_TESTS=OFF \
              -DgRPC_INSTALL=ON \
              -DgRPC_ABSEIL_CPP_PROVIDER=module \
              -DgRPC_SSL_PROVIDER=module \
              -DgRPC_ABSL_PROVIDER=module     \
              -DgRPC_CARES_PROVIDER=module    \
              -DgRPC_PROTOBUF_PROVIDER=module \
              -DgRPC_ZLIB_PROVIDER=module \
              -DgRPC_ENVOY_API_PROVIDER=module \
              -DgRPC_PROTOC_GEN_VALIDATE_PROVIDER=module \
              ../.. && \
        make -j2 && \
        make install && ldconfig && \
        popd && \
        cd .. && rm -fr grpc && \
        :   

############################################################################
# setup an user
############################################################################
ARG     USER_ID=1000
ARG     GROUP_ID=100
RUN     set -x && \
        groupadd \
            --system \
            --gid ${GROUP_ID} \
            eindemwort \
            && \
        useradd \
            --system \
            --no-log-init \
            --create-home \
            --uid ${USER_ID} \
            --gid ${GROUP_ID} \
            eindemwort \
            && \
        :
USER    eindemwort