#!/usr/bin/env bash

RELEASE_ARGS="${@:-rake release}"
IMAGE=ruby:2.6

docker run -it --rm \
  -w /app \
  -v $(pwd):/app \
  -v $HOME/.gem:/root/.gem \
  $IMAGE \
  $RELEASE_ARGS
