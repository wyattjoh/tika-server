# tika-server

Configurable Apache Tika Server Docker Image with Tesseract 4.

## Contents

- Apache Tika 1.20
- Tesseract OCR 4
- Tesseract Language Packs: English, Italian, French, Spain, German, Russian

Allows providing external configuration file for Tika Server - for disabling OCR or any other needs.

## Running

**Pulling wyattjoh/tika-server:**

```sh
docker pull wyattjoh/tika-server
```

**Simply running Tika Server with default config and publishing Tika port on the host machine:**

```sh
docker run -p 9998:9998 -it wyattjoh/tika-server
```

**Running Tika Server with external configuration:**

1. Create tika-config.xml file.
   The following example tika-config.xml can be used for disabling OCR:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<properties>
  <parsers>
      <parser class="org.apache.tika.parser.DefaultParser">
          <parser-exclude class="org.apache.tika.parser.ocr.TesseractOCRParser"/>
      </parser>
  </parsers>
</properties>
```

2. Run Tika server with this config file:

```sh
docker run -it -p 9998:9998 -v $PWD/tika-config.xml:/tika-config.xml wyattjoh/tika-server
```
