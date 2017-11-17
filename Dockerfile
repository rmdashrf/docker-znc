FROM ubuntu:16.04

ENV ZNC_VERSION 1.7.x-git

RUN apt-get update \
    && apt-get install -y sudo wget build-essential libssl-dev libperl-dev \
               pkg-config swig3.0 libicu-dev ca-certificates python3-dev ca-certificates libcurl4-openssl-dev git cmake

RUN mkdir -p /src \
    && cd /src \
    && git clone --depth=1 'https://github.com/CyberShadow/znc-clientbuffer' /src/znc-clientbuffer \
    && git clone --depth=1 'https://github.com/jreese/znc-push' /src/zncpush \
    && git clone --recursive 'https://github.com/znc/znc' /src/znc \
    && ln -s /src/znc-clientbuffer/clientbuffer.cpp /src/znc/modules/clientbuffer.cpp \
    && ln -s /src/zncpush/push.cpp /src/znc/modules/push.cpp \
    && mkdir -p /src/znc/build && cd /src/znc/build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j8 install \
    && rm -rf /src \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /src /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd znc
ADD docker-entrypoint.sh /entrypoint.sh
ADD znc.conf.default /znc.conf.default
RUN chmod 644 /znc.conf.default

VOLUME /znc-data

EXPOSE 6667
ENTRYPOINT ["/entrypoint.sh"]
