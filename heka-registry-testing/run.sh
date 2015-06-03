#!/bin/bash

docker run -ti \
  --rm \
  --name heka-testing \
  -p 4352:4352 \
  scratch/heka-testing
