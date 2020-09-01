FROM continuumio/miniconda2:latest
MAINTAINER po-e@lanl.gov

LABEL version="1.0.0"
LABEL software="nmdc_taxa_profilers"
LABEL tags="bioinformatics"

ENV container docker

# prepare directories for inputs and databases
RUN mkdir -p /data && mkdir -p /databases
RUN conda config --add channels conda-forge && \
    conda config --add channels bioconda
# install gottcha2
RUN conda install -y unzip && \
    wget https://github.com/poeli/GOTTCHA2/archive/master.zip && \
    unzip master.zip && cp GOTTCHA2-master/*.py /opt/conda/bin && \
    conda install -y minimap2 && \
    conda install -y pandas
# install kraken2
RUN conda install -c bioconda -y kraken2
# install centrifuge
RUN conda install -c bioconda -y centrifuge

WORKDIR /data

CMD ["/bin/bash"]
