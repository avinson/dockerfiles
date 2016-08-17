#!/bin/bash
set -e

# rsync only files that have newer timestamp so don't overwrite our stuffs
rsync --update -raz --progress /bayesdb/demo/Bayeslite-v${BAYESLITE_VERSION}/ /notebooks/
exec ipython notebook --port=8888 --ip=0.0.0.0 --no-browser /notebooks/Index.ipynb
