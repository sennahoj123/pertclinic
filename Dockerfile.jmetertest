FROM alpine:3.18

ARG JMETER_VERSION="5.6.3"

ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN /opt/apache-jmeter-${JMETER_VERSION}/bin
ENV JMETER_DOWNLOAD_URL https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

RUN apk update && \
    apk add openjdk11 curl && \
    rm -rf /var/cache/apk/*

WORKDIR /opt

RUN curl -L ${JMETER_DOWNLOAD_URL} | tar -xz

WORKDIR ${JMETER_HOME}

ADD petclinic_load_test.jmx ${JMETER_BIN}

WORKDIR ${JMETER_BIN}

RUN mkdir results

ENTRYPOINT ["./jmeter", "-n", "-t", "./petclinic_load_test.jmx", "-l", "/opt/apache-jmeter-5.6.3/bin/results/testresultsiede.jtl"]
