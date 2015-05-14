#!/usr/bin/env bash

# match ops group for docker socket access
groupadd -g 999 heka
useradd -ms /bin/bash -g heka heka

mkdir -p /var/cache/hekad

chown heka /var/cache/hekad

exec /usr/bin/hekad --config /config.toml

