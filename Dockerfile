FROM ubuntu:18.04

ENV TIKA_VERSION 1.22
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

EXPOSE 9998

RUN apt-get -y --fix-missing update

RUN apt-get install -y gpg curl gdal-bin openjdk-8-jre-headless

# Other language packs:
# - tesseract-ocr-ita
# - tesseract-ocr-fra
# - tesseract-ocr-spa
# - tesseract-ocr-deu
# - tesseract-ocr-rus

RUN apt-get -y install tesseract-ocr tesseract-ocr-eng \
    && tesseract -v

RUN curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
    && gpg --import /tmp/tika.asc \
    && curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-${TIKA_VERSION}.jar.asc \
    && NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
    | awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
    | sed -r -e 's/^"//; s/",$//; s/" "//') \
    && echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
    && curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tika-server-${TIKA_VERSION}.jar


RUN apt-get -y clean autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT java -jar tika-server-${TIKA_VERSION}.jar --h 0.0.0.0 --port 9998
