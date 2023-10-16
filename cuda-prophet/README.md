## Overview

Docker image for [NeuralProphet](https://github.com/ourownstory/neural_prophet) using a [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda/) base image for GPU acceleration and Jupyter functionality borrowed from the [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) project.

* NeuralProphet 1.0.0rc4
* CUDA 11.8
* PyTorch 2.0.0

## Setup
* Follow the instructions [here](https://support.system76.com/articles/cuda/#other-versions-of-cuda) to install the `nvidia-container-toolkit` and the other changes necessary for CUDA to run in Docker.
* Test that CUDA is available by running this command: `docker run --rm --runtime=nvidia --gpus all avinson/cuda-prophet python -c "import torch; print(torch.cuda.is_available())"`

## Start Jupyter
* `wget https://raw.githubusercontent.com/avinson/dockerfiles/master/cuda-prophet/docker-compose.yml && docker compose up` -- to get a Jupyter instance with NeuralProphet and CUDA support

## Misc
Dockerfile and other files are here: https://github.com/avinson/dockerfiles/tree/master/cuda-prophet
