FROM mitprobcomp/bayeslite-notebook

ENV BAYESLITE_VERSION 0.1.8.1

VOLUME /notebooks
VOLUME /csv

ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
ENTRYPOINT docker-entrypoint.sh
