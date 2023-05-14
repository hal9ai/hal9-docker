ARG UBUNTU_VERSION=20.04
ARG CUDA=11.8.0

FROM nvidia/cuda:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base

ARG BUILD_DATE
ENV BUILD_DATE ${BUILD_DATE:-2019-11-19}
ENV LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

LABEL org.label-schema.vcs-url="https://github.com/hal9ai/hal9-docker" \
      org.label-schema.vendor="Hal9 Inc" \
      maintainer="Javier Luraschi <info@hal9.ai>" \
      com.nvidia.volumes.needed="nvidia_driver"

ARG DEBIAN_FRONTEND=noninteractive

# Locales
RUN apt-get clean
RUN apt-get update
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libcurl3-dev \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libzmq3-dev \
    pkg-config \
    rsync \
    software-properties-common \
    unzip \
    zip \
    zlib1g-dev \
    wget \
    git \
    gzip \
    perl

# install posgresql
RUN apt update
RUN apt install -y postgresql postgresql-contrib
RUN service postgresql start

# chrome headless
RUN apt-get install -y \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    libgbm1 \
    libgbm-dev

# locales
RUN apt-get update
RUN apt-get install -y locales

# upgrade node
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs

# install python
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt install -y python3.9
RUN apt install -y python3-pip
RUN pip3 install numpy scikit-learn pandas xgboost tensorflow scipy pycaret
RUN pip3 install scikit-image pyexiftool

# install r package deps (xml, httr, libgdal-dev)
RUN apt install -y libxml2-dev libssl-dev libgdal-dev
RUN apt-get install -y pandoc
RUN apt install -y libfontconfig1-dev

# install r
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN apt install -y r-base
RUN apt install -y build-essential
RUN R -e "options(repos = c(REPO_NAME = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest')); install.packages(c('jsonlite', 'tidyverse', 'pins', 'torch', 'torchvision', 'tidymodels', 'BiocManager', 'ghql'))"
RUN R -e "BiocManager::install('plsmod', ask = FALSE)"

# addon packages
RUN pip3 install pandas torch torchvision Pillow transformers keybert pytorch-lightning
RUN R -e "options(repos = c(CRAN = 'http://cran.rstudio.com')); install.packages(c('plotly', 'prospectr', 'h2o', 'plumber', 'raster', 'leaflet', 'kable', 'kableExtra', 'tableHTML'))"
RUN pip3 install prophet statsmodels matplotlib numpy==1.21.4 numba==0.53.0 Flask spacy yfinance mediapipe praw psaw
RUN python3 -m spacy download en_core_web_sm

RUN apt install -y default-jre


# install node
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install -y yarn
RUN apt install --no-install-recommends -y yarn
RUN yarn --version

# install rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# backend prereqs
RUN apt install patchelf
RUN pip3 install maturin[patchelf]==0.13.7 uvicorn fastapi auto-sklearn
