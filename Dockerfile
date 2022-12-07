#FROM apache/skywalking-java-agent:8.9.0-alpine as skywalking
#FROM bitnami/jmx-exporter:latest as jmx-exporter

FROM alpine:3.17

ENV TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 UMASK=0022
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

#COPY --from=skywalking  /skywalking/agent/          /app/skywalking/
#COPY --from=jmx-exporter /opt/bitnami/jmx-exporter/ /app/jmx-exporter/

# yum only: yum-utils createrepo crontabs curl-minimal dejavu-sans-fonts iproute java-11-openjdk-devel java-17-openjdk-devel telnet traceroute pcre-devel pcre2-devel 
# alpine: openjdk8 openjdk11-jdk openjdk17-jdk font-noto-cjk consul vim
RUN set -eux; addgroup -g 8080 app ; adduser -u 8080 -S -G app -s /bin/bash app ;\
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g' /etc/apk/repositories ;\
    echo -e 'export PATH=$JAVA_HOME/bin:$PATH\nexport JMX_PORT=${JMX_PORT:-"5555"}\nexport JMX_EXPT=${JMX_EXPT:-"5556"}' | tee  /etc/profile.d/91-env.sh ;\
    echo -e "export IPV4=\$(ip route get 8.8.8.8 | grep src | awk '{print \$7}')" | tee -a /etc/profile.d/91-env.sh ;\
    echo -e 'export JMX_HOST=${IPV4}' | tee -a /etc/profile.d/91-env.sh ;\
    echo -e 'export JMX_OPTS=" -Dcom.sun.management.jmxremote.port=${JMX_PORT} -Dcom.sun.management.jmxremote.rmi.port=${JMX_PORT}  \
        -Djava.rmi.server.hostname=${JMX_HOST} -Dcom.sun.management.jmxremote.host=${JMX_HOST} \
        -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false " '\
        | tee -a /etc/profile.d/91-env.sh ;\
    echo -e 'export JAVA_TOOL_OPTIONS="${JAVA_OPTS} ${JAVA_EXT_OPTS} ${XMX_OPTS} ${JAVA_AGENT_OPTS}  ${JAVA_AGENT_PROMETHEUS_OPTS} ${JAVA_AGENT_SKYWALKING_OPTS}" '| tee -a /etc/profile.d/91-env.sh ;\
    apk add --no-cache fontconfig libretls musl-locales musl-locales-lang ttf-dejavu tzdata zlib \
        bash busybox-extras ca-certificates curl wget iproute2 iputils inetutils-ftp runit dumb-init tini gnupg libcap openssl su-exec sudo jq libc6-compat iptables tzdata \
        procps less unzip  tcpdump  net-tools socat jq mtr psmisc logrotate  tomcat-native \
        runit pcre-dev pcre2-dev openssl1.1-compat  openssh-client-default iperf3 wrk atop htop iftop tmux vim  ;\    
    rm -rf /tmp/* /var/cache/apk/*;
    
    
