# Base image
FROM python:3.6

RUN mkdir /training
WORKDIR /training

# Copying requirements.txt file
COPY pip_req_frozen.txt requirements.txt

# pip install
RUN pip install -r requirements.txt

RUN git clone https://github.com/facebookresearch/fastText.git && cd fastText && make

ENTRYPOINT /bin/bash
