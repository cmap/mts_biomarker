#!/usr/bin/env bash

#change the version number for each new build

docker build -t cmap/cdsr_biomarker:latest -t cmap/cdsr_biomarker:v0.0.1 --rm=true .
