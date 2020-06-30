FROM openjdk:14-slim as builder

ARG MX_VERSION=5.265.11
ARG GRAAL_VERSION=20.1.0

RUN apt-get update \
  && apt-get install -y git python2.7 make gcc g++ \
  && git clone https://github.com/graalvm/mx.git --branch ${MX_VERSION} --depth 1 \
  && export PATH=$PWD/mx:$PATH \
  && git clone https://github.com/oracle/graal.git --branch vm-${GRAAL_VERSION} --depth 1 \
  && mx --primary-suite-path /graal/compiler --java-home=${JAVA_HOME} gate --strict-mode --tags build

FROM debian:buster-slim

ENV LANG C.UTF-8
ENV JAVA_HOME /usr/java/openjdk-14
ENV PATH $JAVA_HOME/bin:$PATH
ENV JAVA_VERSION 14

COPY --from=builder /graal/sdk/mxbuild/linux-amd64/GRAALVM_3398AB5293_JAVA14/graalvm-3398ab5293-java14-20.1.0 /usr/java/openjdk-14

RUN set -eux; \
  	apt-get update; \
  	apt-get install -y --no-install-recommends ca-certificates p11-kit; \
  	rm -rf /var/lib/apt/lists/*; \
    ln -s /usr/java/openjdk-14 /docker-java-home

CMD ["jshell"]
