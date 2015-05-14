FROM ubuntu:14.04

ENV HEKA_VERSION 0.9.2

RUN apt-get update
RUN apt-get install -yq wget lua-cjson && apt-get clean

WORKDIR /

RUN wget https://github.com/mozilla-services/heka/releases/download/v${HEKA_VERSION}/heka_${HEKA_VERSION}_amd64.deb && dpkg -i heka_${HEKA_VERSION}_amd64.deb

ADD ./docker_json.lua /usr/share/heka/lua_decoders/docker_json.lua
ADD . /

# heka dashboard
EXPOSE 4352

ENTRYPOINT [ "/init.sh" ]
