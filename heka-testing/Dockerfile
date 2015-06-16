FROM ubuntu:14.04

ENV HEKA_VERSION 0.9.2

RUN apt-get update
RUN apt-get install -yq wget lua-cjson luarocks postgresql postgresql-contrib libpq-dev && apt-get clean
RUN luarocks install luasql-postgres PGSQL_INCDIR=/usr/include/postgresql PGSQL_DIR=/usr/bin 

WORKDIR /

RUN wget https://github.com/mozilla-services/heka/releases/download/v${HEKA_VERSION}/heka_${HEKA_VERSION}_amd64.deb && dpkg -i heka_${HEKA_VERSION}_amd64.deb

ADD ./docker_json.lua /usr/share/heka/lua_decoders/docker_json.lua
ADD ./redshift.lua /usr/share/heka/lua_decoders/redshift.lua
ADD . /

RUN mkdir /usr/share/heka/lua_modules/luasql
RUN ln -s /usr/local/lib/lua/5.1/luasql/postgres.so /usr/share/heka/lua_modules/luasql/postgres.so

# heka dashboard
EXPOSE 4352

ENTRYPOINT [ "/init.sh" ]
