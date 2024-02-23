FROM hal9ai/hal9-docker:0.1.1 as base

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

RUN apt-get update \
    && apt-get install -y tdsodbc unixodbc-dev \
    && apt install unixodbc -y \
    && apt-get clean -y

RUN mkdir /hal9
COPY requirements.txt /hal9

RUN pip3 install -r /hal9/requirements.txt
