# Base image
FROM python:3.6

RUN mkdir /training
WORKDIR /training

# Can set environment variables like this:
#ENV RAW_DATA_PATH=/training/data/raw-data

# install ICU
RUN svn export http://source.icu-project.org/repos/icu/tags/release-62-1/icu4c && cd icu4c/source && chmod +x runConfigureICU configure install-sh && ./runConfigureICU Linux && make && make install && cd ../..
ENV LD_LIBRARY_PATH /usr/local/lib

# Copying requirements.txt file
COPY requirements.txt requirements.txt

# pip install
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Problems installing cython and pyfasttext using requirements.txt, so do it here:
RUN pip install --upgrade cython && \
    pip install --upgrade cysignals && \
    pip install pyfasttext

# install fastText
RUN git clone https://github.com/facebookresearch/fastText.git && cd fastText && make

# install nano
RUN apt-get update && apt-get install nano

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		fonts-texgyre \
	&& rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
        && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default

ENV R_BASE_VERSION 3.5.3

## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
## Also install stringr to make dococt install (from source) easier.
## Also install some of my fav. tidyverse packages like ggplot2, dplyr etc
RUN apt-get update \
	&& apt-get install -t unstable -y --no-install-recommends \
		littler \
                r-cran-littler \
                r-cran-stringr \
                r-cran-ggplot2 \
                r-cran-dplyr \
                r-cran-readr \
                r-cran-tidyr \
                r-cran-purrr \
                r-cran-tibble \
                r-cran-data.table \
		r-base=${R_BASE_VERSION}-* \
		r-base-dev=${R_BASE_VERSION}-* \
		r-recommended=${R_BASE_VERSION}-* \
        && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"))' >> /etc/R/Rprofile.site \
        && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*

# If "r-cran-" above does not work install other R packages with:
RUN Rscript -e "install.packages('partykit')"

# start image at command line
CMD /bin/bash

# Add Users
RUN useradd -m dan-the-man
USER dan-the-man

# Set time zone
ENV TZ Australia/Melbourne
