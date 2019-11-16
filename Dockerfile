FROM ubuntu:18.04

ENV PRODUCT_GROUP "tika"
ENV PRODUCT_NAME "tika-server"
ENV PRODUCT_VERSION "1.22"

# Apache Project

ENV PRODUCT_ROOT "https://www.apache.org/dist"
ENV PRODUCT_KEY_URL "${PRODUCT_ROOT}/${PRODUCT_GROUP}/KEYS"
ENV PRODUCT_ASC_URL "${PRODUCT_ROOT}/${PRODUCT_GROUP}/${PRODUCT_NAME}-${PRODUCT_VERSION}.jar.asc"

RUN apt-get -y --fix-missing update \
    && apt-get install -y gpg curl jq \
    && echo "PRODUCT_GROUP = ${PRODUCT_GROUP}" \
    && echo "PRODUCT_NAME = ${PRODUCT_NAME}" \
    && echo "PRODUCT_VERSION = ${PRODUCT_VERSION}" \
    && echo "PRODUCT_ROOT = ${PRODUCT_ROOT}" \
    && echo "PRODUCT_KEY_URL = ${PRODUCT_KEY_URL}" \
    && echo "PRODUCT_ASC_URL = ${PRODUCT_ASC_URL}" \
    && curl -sSL "$PRODUCT_KEY_URL" -o /tmp/KEYS \
    && gpg --import /tmp/KEYS \
    && curl -sSL "$PRODUCT_ASC_URL" -o "/tmp/${PRODUCT_NAME}.jar.asc" \
    && NEAREST_JAR_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${PRODUCT_JAR_URL#https://www.apache.org/dist/}\?asjson\=1 | jq -r .preferred | sed 's/\/*$//g') \
    && echo "NEAREST_JAR_URL = ${NEAREST_JAR_URL}" \
    && curl -sSL "${NEAREST_JAR_URL}/${PRODUCT_GROUP}/${PRODUCT_NAME}-${PRODUCT_VERSION}.jar" -o "/${PRODUCT_NAME}.jar" \
    && gpg --verify "/tmp/${PRODUCT_NAME}.jar.asc" "/${PRODUCT_NAME}.jar"

FROM openjdk:8

EXPOSE 9998

RUN apt-get -y --fix-missing update \
    && apt-get install -y gdal-bin tesseract-ocr tesseract-ocr-eng \
    && tesseract -v \
    && apt-get -y clean autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /usr/src/app
COPY --from=0 /tika-server.jar /usr/src/app

ENTRYPOINT java -jar "tika-server.jar" --h 0.0.0.0 --port 9998
