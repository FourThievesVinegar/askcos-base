FROM continuumio/miniconda3:4.8.3-alpine

USER root

RUN apk update && apk upgrade && apk add bash

COPY environment.yml /tmp/environment.yml

RUN /usr/sbin/addgroup -S askcos && \
    /usr/sbin/adduser -D -u 1000 askcos -G askcos && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/askcos/.profile && \
    echo "conda activate base" >> /home/askcos/.profile

RUN /opt/conda/bin/conda config --set channel_priority strict 
# && \
#    /opt/conda/bin/conda update conda


RUN /opt/conda/bin/conda env update -vv --file /tmp/environment.yml && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afyv

RUN /opt/conda/bin/conda install pip

# Use non-AVX version of tensorflow
COPY tensorflow-2.0.0a0-cp37-cp37m-linux_x86_64.whl tensorflow-2.0.0a0-cp37-cp37m-linux_x86_64.whl
RUN pip install tensorflow-2.0.0a0-cp37-cp37m-linux_x86_64.whl

# Manually fix https://github.com/rdkit/rdkit/issues/2854
RUN sed -i 's/latin1/utf-8/g' /opt/conda/lib/python3.7/site-packages/rdkit/Chem/Draw/cairoCanvas.py

USER askcos

ENV PATH=/opt/conda/bin${PATH:+:${PATH}}
ENV PYTHONPATH=/opt/conda/share/RDKit/Contrib${PYTHONPATH:+:${PYTHONPATH}}
