#!/usr/bin/env bash

TEST_ARGS="${@:-bundle exec rspec spec}"
IMAGE=ruby:2.6

docker volume create cassette-gems && \
  docker run -it --rm \
    -w /app \
    -v $(pwd):/app \
    -v $HOME/.gem:/root/.gem \
    -v cassette-gems:/gems \
    -e BUNDLE_PATH=/gems \
    -e BUNDLE_JOBS=4 \
    $IMAGE \
    $TEST_ARGS
