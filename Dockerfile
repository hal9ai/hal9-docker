FROM hal9ai/hal9-docker:0.1.1 as base

ARG DRIVER_MAJOR_VERSION="2.6.26"
ARG DRIVER_MINOR_VERSION=1045
ARG BUCKET_URI="https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc"
ENV DRIVER_FULL_VERSION=${DRIVER_MAJOR_VERSION}.${DRIVER_MINOR_VERSION}
ENV FOLDER_NAME=SimbaSparkODBC-${DRIVER_FULL_VERSION}-Debian-64bit
ENV ZIP_FILE_NAME=${FOLDER_NAME}.zip
RUN apt-get update -y && \
    apt-get install -y unzip unixodbc-dev unixodbc build-essential cmake make procps && \
    wget ${BUCKET_URI}/${DRIVER_MAJOR_VERSION}/${ZIP_FILE_NAME} && \
    unzip ${ZIP_FILE_NAME} && rm -f ${ZIP_FILE_NAME} && \
    apt-get install -y ./*.deb
RUN pip3 install pyodbc

RUN pip3 install streamlit==1.15.2 snowflake-connector-python==3.0.2 altair==4.0
RUN pip3 install --upgrade requests

RUN sed -i 's/<head>/<head><script src="..\/..\/h9.runtime.js"><\/script><script src="https:\/\/cdn.jsdelivr.net\/npm\/hal9@0.3.112\/dist\/hal9.min.js"><\/script>/g' /usr/local/lib/python3.8/dist-packages/streamlit/static/index.html 

RUN sed -i 's/<body>/<body>[ Loading ]/g' /usr/local/lib/python3.8/dist-packages/streamlit/static/index.html 

RUN sed -i 's/<\/body>/<style>\.block-container { max-width: none; }<\/style><\/body>/g' /usr/local/lib/python3.8/dist-packages/streamlit/static/index.html 

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs
RUN apt install -y sudo
