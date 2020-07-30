FROM cmap/base-clue-mts:latest
MAINTAINER Andrew Boghossian <cmap-soft@broadinstitute.org>

COPY ./install_scripts.R /src/install_scripts.R
RUN Rscript /src/install_scripts.R

COPY run_script.R /run_script.R
COPY ./run_script.sh /clue/bin/run_script

WORKDIR /
ENV PATH /clue/bin:$PATH
RUN ["chmod","-R", "+x", "/clue/bin"]
ENTRYPOINT ["run_script"]
