FROM cmap/base-clue-mts:latest
MAINTAINER Andrew Boghossian <cmap-soft@broadinstitute.org>

COPY ./install_scripts.R /src/install_scripts.R
RUN Rscript /src/install_scripts.R

COPY ./run_script.R /run_script.R
COPY ./aws_batch.sh /clue/bin/aws_batch

WORKDIR /
ENV PATH /clue/bin:$PATH
RUN ["chmod","-R", "+x", "/clue/bin"]
ENTRYPOINT ["aws_batch"]
