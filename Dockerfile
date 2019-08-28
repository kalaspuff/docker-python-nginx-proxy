FROM debian:stretch-20190812-slim AS builder

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /

RUN mkdir /logs

RUN apt-get -y update && apt-get install -y \
    procps=2:3.3.12-3+deb9u1 \
    curl=7.52.1-5+deb9u9 \
    unzip=6.0-21+deb9u1 \
    vim=2:8.0.0197-4+deb9u3 \
    nano=2.7.4-1 \
    netcat=1.10-41 \
    libreadline7=7.0-3 \
    libgdbm3=1.8.3-14 \
    libexpat1=2.2.0-2+deb9u1 \
    net-tools=1.60+git20161116.90da8a0-1 \
    git=1:2.11.0-3+deb9u4 \
    ca-certificates=20161130+nmu1+deb9u1

RUN apt-get -y update && apt-get install -y \
    libpcre3-dev=2:8.39-3 \
    zlib1g-dev=1:1.2.8.dfsg-5 \
    libssl-dev=1.1.0k-1~deb9u1 \
    libreadline-dev=7.0-3 \
    libncursesw5-dev=6.0+20161126-1+deb9u2 \
    libncurses5-dev=6.0+20161126-1+deb9u2 \
    libffi-dev=3.2.1-6 \
    libbz2-dev=1.0.6-8.1 \
    liblzma-dev=5.2.2-1.2+b1 \
    libexpat1-dev=2.2.0-2+deb9u1 \
    libgdbm-dev=1.8.3-14 \
    tcl-dev=8.6.0+9 \
    tk-dev=8.6.0+9 \
    gnupg=2.1.18-8~deb9u4 \
    dirmngr=2.1.18-8~deb9u4 \
    dnsutils=1:9.10.3.dfsg.P4-12.3+deb9u5 \
    dh-autoreconf=14 \
    build-essential=12.3

RUN curl -L -o /tmp/nginx.tar.gz https://nginx.org/download/nginx-1.16.1.tar.gz \
    && tar -zxf /tmp/nginx.tar.gz -C /tmp/ \
    && mv /tmp/nginx-1.16.1 /tmp/nginx \
    && cd /tmp/nginx \
    && ./configure --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
    && make \
    && make install \
    && rm -rf /tmp/nginx /tmp/nginx.tar.gz

RUN curl -L -o /tmp/python.tar.gz https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz \
    && tar -zxf /tmp/python.tar.gz -C /tmp/ \
    && mv /tmp/Python-3.7.4 /tmp/python \
    && cd /tmp/python \
    && ./configure --enable-optimizations --with-lto \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /tmp/python /tmp/python.tar.gz \
    && rm -rf /usr/local/lib/python3.7/test /usr/local/lib/python3.7/config-3.7m-x86_64-linux-gnu

RUN curl -L -o /tmp/protobuf.tar.gz https://github.com/protocolbuffers/protobuf/archive/v3.9.1.tar.gz \
    && tar -zxf /tmp/protobuf.tar.gz -C /tmp/ \
    && rm /tmp/protobuf.tar.gz \
    && cd /tmp/protobuf-3.9.1 \
    && ./autogen.sh \
    && CXXFLAGS="-fno-delete-null-pointer-checks" ./configure --disable-shared \
    && make \
    && cp src/protoc /usr/local/bin/protoc \
    && ln -s /usr/local/bin/protoc /usr/bin/protoc \
    && cd src \
    && mkdir -p /usr/local/include \
    && find . -name *.proto -type f -exec tar -zcf proto-includes.tar.gz {} + \
    && tar -zxf proto-includes.tar.gz -C /usr/local/include/

RUN ln -s /usr/local/bin/python3 /usr/local/bin/python \
    && ln -s /usr/local/bin/python3 /usr/bin/python \
    && ln -s /usr/local/bin/python3 /usr/bin/python3 \
    && ln -s /usr/local/bin/python3 /usr/bin/python3.7 \
    && ln -s /usr/local/bin/python3-config /usr/local/bin/python-config \
    && ln -s /usr/local/bin/python3-config /usr/bin/python-config \
    && ln -s /usr/local/bin/python3-config /usr/bin/python3-config \
    && ln -s /usr/local/bin/pip3 /usr/local/bin/pip \
    && ln -s /usr/local/bin/pip3 /usr/bin/pip \
    && ln -s /usr/local/bin/pip3 /usr/bin/pip3 \
    && ln -s /usr/local/bin/pip3 /usr/bin/pip3.7 \
    && ln -s /usr/local/bin/idle3 /usr/local/bin/idle \
    && ln -s /usr/local/bin/idle3 /usr/bin/idle \
    && ln -s /usr/local/bin/idle3 /usr/bin/idle3 \
    && ln -s /usr/local/bin/idle3 /usr/bin/idle3.7

RUN pip install --upgrade pip==19.2.3

RUN curl -L -o /tmp/get-poetry.py https://raw.githubusercontent.com/sdispater/poetry/0.12.7/get-poetry.py \
    && python /tmp/get-poetry.py --yes --version 0.12.7 \
    && rm -f /tmp/get-poetry.py \
    && mv /root/.poetry /usr/local/lib/poetry \
    && (echo 'python /usr/local/lib/poetry/bin/poetry "$@"' > /usr/local/bin/poetry) \
    && chmod +x /usr/local/bin/poetry \
    && ln -s /usr/local/bin/poetry /usr/bin/poetry \
    && poetry config settings.virtualenvs.create 0

ADD utils/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
ADD utils/init.d/nginx /etc/init.d/nginx
ADD utils/bashrc/bashrc /root/.bashrc
ADD utils/vimrc/vimrc /etc/vim/vimrc
ADD utils/vimrc/vimrc /root/.vimrc
ADD utils/sshconfig/config /root/.ssh/config
ADD utils/utils/start-service /bin/start-service
RUN chmod +x /etc/init.d/nginx /bin/start-service

RUN mkdir -p /etc/security
RUN echo '' >> /etc/security/limits.conf
RUN echo '* hard core 0' >> /etc/security/limits.conf
RUN echo '* soft core 0' >> /etc/security/limits.conf
RUN echo '' >> /etc/sysctl.conf
RUN echo 'fs.suid_dumpable=0' >> /etc/sysctl.conf

RUN service nginx start
EXPOSE 80

RUN (host=github.com; ssh-keyscan -H $host; for ip in $(dig @1.1.1.1 github.com +short); do ssh-keyscan -H $host,$ip; ssh-keyscan -H $ip; done) 2> /dev/null >> /root/.ssh/known_hosts

RUN apt-get purge -y --auto-remove \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    libreadline-dev \
    libncurses5-dev \
    libffi-dev \
    libbz2-dev \
    liblzma-dev \
    libexpat1-dev \
    libgdbm-dev \
    tcl-dev \
    tk-dev \
    gnupg \
    dirmngr \
    dnsutils \
    dh-autoreconf \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT [ "start-service" ]

CMD /bin/bash
