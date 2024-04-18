FROM alpine:3.18

ARG JMETER_VERSION="5.6.3"

ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN /opt/apache-jmeter-${JMETER_VERSION}/bin
ENV JMETER_DOWNLOAD_URL https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
WORKDIR ${JMETER_HOME}

#COPY Entry.sh /Entry.sh

RUN apk update && \
    apk add openjdk11 && \
    apk add curl && \
    curl -L ${JMETER_DOWNLOAD_URL} | tar -xz && \
    ln -s ${JMETER_HOME}/apache-jmeter-${JMETER_VERSION}/* ${JMETER_HOME} && \
    rm -rf /var/cache/apk/* #&& \
    chmod a+x /Entry.sh

COPY ./petclinic_load_test.jmx ${JMETER_BIN}

ENTRYPOINT ["./jmeter", "-n", "-t", "/opt/apache-jmeter-${JMETER_VERSION}/bin/petclinic_load_test.jmx", "-l", "testresultsiede.jtl"]

