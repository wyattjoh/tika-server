FROM ubuntu:18.04

ENV TIKA_VERSION 1.22
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

EXPOSE 9998

RUN apt-get -y --fix-missing update

RUN apt-get install -y gpg curl jq gdal-bin openjdk-8-jre-headless tesseract-ocr tesseract-ocr-eng \
    && tesseract -v

RUN curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
    && gpg --import /tmp/tika.asc \
    && curl -sSL "$TIKA_SERVER_URL.asc" -o "/tmp/tika-server-${TIKA_VERSION}.jar.asc" \
    && NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 | jq -r .preferred) \
    && echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
    && curl -sSL "$NEAREST_TIKA_SERVER_URL" -o "/tika-server-${TIKA_VERSION}.jar"

RUN apt-get -y clean autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT java -jar "tika-server-${TIKA_VERSION}.jar" --h 0.0.0.0 --port 9998
