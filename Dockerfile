FROM debian:stretch-slim AS builder

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /

RUN mkdir /logs

RUN apt-get -y update && apt-get install -y \
    procps=2:3.3.12-3 \
    curl=7.52.1-5+deb9u6 \
    unzip=6.0-21 \
    vim=2:8.0.0197-4+deb9u1 \
    nano=2.7.4-1 \
    netcat=1.10-41 \
    net-tools=1.60+git20161116.90da8a0-1 \
    git=1:2.11.0-3+deb9u2

RUN apt-get -y update && apt-get install -y \
    libpcre3-dev=2:8.39-3 \
    zlib1g-dev=1:1.2.8.dfsg-5 \
    libssl-dev=1.1.0f-3+deb9u2 \
    libreadline-dev=7.0-3 \
    libncurses5-dev=6.0+20161126-1+deb9u2 \
    libffi-dev=3.2.1-6 \
    dnsutils=1:9.10.3.dfsg.P4-12.3+deb9u4 \
    build-essential=12.3

RUN curl -L -o /tmp/nginx.tar.gz https://nginx.org/download/nginx-1.14.0.tar.gz \
    && tar -zxf /tmp/nginx.tar.gz -C /tmp/ \
    && mv /tmp/nginx-1.14.0 /tmp/nginx \
    && cd /tmp/nginx \
    && ./configure --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
    && make \
    && make install \
    && rm -rf /tmp/nginx /tmp/nginx.tar.gz

RUN curl -L -o /tmp/python.tar.gz https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz \
    && tar -zxf /tmp/python.tar.gz -C /tmp/ \
    && mv /tmp/Python-3.6.5 /tmp/python \
    && cd /tmp/python \
    && ./configure --enable-optimizations --with-lto \
    && make \
    && make install \
    && rm -rf /tmp/python /tmp/python.tar.gz \
    && rm -rf /usr/local/lib/python3.6/test /usr/local/lib/python3.6/config-3.6m-x86_64-linux-gnu

RUN ln -s /usr/local/bin/python3 /usr/local/bin/python \
    && ln -s /usr/local/bin/python3 /usr/bin/python \
    && ln -s /usr/local/bin/python3 /usr/bin/python3 \
    && ln -s /usr/local/bin/python3 /usr/bin/python3.6 \
    && ln -s /usr/local/bin/python3-config /usr/local/bin/python-config \
    && ln -s /usr/local/bin/python3-config /usr/bin/python-config \
    && ln -s /usr/local/bin/python3-config /usr/bin/python3-config \
    && ln -s /usr/local/bin/pip3 /usr/local/bin/pip \
    && ln -s /usr/local/bin/pip3 /usr/bin/pip \
    && ln -s /usr/local/bin/pip3 /usr/bin/pip3 \
    && ln -s /usr/local/bin/pip3 /usr/bin/pip3.6

RUN pip install --upgrade pip==10.0.1

ADD utils/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
ADD utils/init.d/nginx /etc/init.d/nginx
ADD utils/bashrc/bashrc /root/.bashrc
ADD utils/vimrc/vimrc /etc/vim/vimrc
ADD utils/vimrc/vimrc /root/.vimrc
ADD utils/sshconfig/config /root/.ssh/config
ADD utils/utils/start-service /bin/start-service
RUN chmod +x /etc/init.d/nginx /bin/start-service

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
    dnsutils \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT [ "start-service" ]

CMD /bin/bash