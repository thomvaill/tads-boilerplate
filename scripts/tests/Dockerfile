FROM ubuntu:18.04

RUN deps="jq" \
    && apt-get update && apt-get install -y --no-install-recommends $deps && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

VOLUME [ "/tmp/tads" ]
