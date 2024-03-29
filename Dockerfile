FROM apache/skywalking-java-agent:8.9.0-alpine as skywalking

FROM bitnami/jmx-exporter:latest as jmx-exporter

FROM alpine:3.15

ENV TZ=Asia/Shanghai LANG=C.UTF-8

COPY --from=skywalking  /skywalking/agent/          /app/skywalking/

COPY --from=jmx-exporter /opt/bitnami/jmx-exporter/ /app/jmx-exporter/

# yum only: yum-utils createrepo crontabs curl-minimal dejavu-sans-fonts iproute java-11-openjdk-devel java-17-openjdk-devel telnet traceroute pcre-devel pcre2-devel 
# alpine: openjdk8 openjdk11-jdk openjdk17-jdk font-noto-cjk consul vim
RUN set -eux; addgroup -g 8080 app ; adduser -u 8080 -S -G app app ;\
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ;\
    apk add --no-cache bash busybox-extras ca-certificates curl wget iproute2 runit dumb-init gnupg libcap openssl su-exec iputils jq libc6-compat iptables tzdata \
        procps  iputils  wget tzdata less   unzip  tcpdump tshark net-tools socat jq mtr psmisc logrotate  tomcat-native \
        runit pcre-dev pcre2-dev  openssh-client-default  luajit luarocks iperf3 wrk atop htop iftop \
        openjdk11-jdk openjdk17-jdk consul consul-template vim ;\
    TOMCAT_VER=`curl --silent https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/ | grep v9 | awk '{split($5,c,">v") ; split(c[2],d,"/") ; print d[1]}'` ;\
    echo $TOMCAT_VER; wget -N https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz -P /tmp ;\
    mkdir -p /usr/local/apache-tomcat; tar zxf /tmp/apache-tomcat-${TOMCAT_VER}.tar.gz -C /usr/local/apache-tomcat --strip-components 1 ;\
    rm -rf /usr/local/apache-tomcat/webapps/* || true;\ 
    
