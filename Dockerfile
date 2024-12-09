FROM python:3.11-slim

RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN apt-get install nodejs npm -y
RUN npm install -g n
RUN n 21

RUN npm --version
RUN make --version

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libgbm1 libasound2 libpangocairo-1.0-0 libxss1 libgtk-3-0

RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

RUN apt-get update && \
    apt-get install -y exiftool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y tdsodbc unixodbc-dev \
    && apt install unixodbc -y \
    && apt-get clean -y

RUN apt-get install -y r-base r-base-dev
RUN Rscript -e 'install.packages(c("tidyverse", "torch", "torchvision", "filelock", "pins", "plumber", "shiny", "renv"))'
RUN Rscript -e 'torch::install_torch()'

RUN mkdir /hal9
COPY requirements.txt /hal9

RUN pip install --upgrade pip
RUN pip install -r /hal9/requirements.txt

RUN apt remove yarn
RUN npm install -g yarn

COPY package.json /hal9

WORKDIR /hal9/
RUN yarn install
