#!/usr/bin/env bash

docker run --rm \
  --name foobar \
  -v /Users/jasiedu/.taiga:/root/.taiga \
  -it cmap/mts_biomarker -d 9

