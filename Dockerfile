FROM alpine:latest

LABEL maintainer="Anton Tyutin <anton@tyutin.ru>"

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apk --no-cache add tzdata \
    && cp /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && echo "UTC" > /etc/timezone \
    && apk del tzdata

RUN apk add --no-cache runit postfix opendkim \
    \
    # opendkim setup
    && chgrp opendkim /etc/opendkim/* \
    && chmod g+r /etc/opendkim/* \
    && adduser postfix opendkim \
    && mkdir -p /opendkim && chown opendkim /opendkim \
    && mkdir -p /run/opendkim && chown opendkim /run/opendkim \
    \
    # postfix setup
    && postconf -e 'myorigin = $mydomain' \
    && postconf -e 'mydestination=' \
    && postconf -e 'mynetworks_style=subnet' \
    && postconf -e 'masquerade_domains=$mydomain' \
    && postconf -e 'smtp_tls_security_level=may' \
    && postconf -e 'milter_default_action=accept' \
    && postconf -e 'milter_protocol=2' \
    && postconf -e 'smtpd_milters=unix:/run/opendkim/opendkim.sock' \
    && postconf -e 'non_smtpd_milters=unix:/run/opendkim/opendkim.sock' \
    \
    && true

COPY conf/opendkim.conf /etc/opendkim/opendkim.conf
COPY runit /supervisor
COPY run.sh /run.sh

CMD ["/run.sh"]
