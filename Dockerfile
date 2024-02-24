FROM docker:25.0.3-alpine3.19

WORKDIR /opt/app

ENV TZ='America/Sao_Paulo'

COPY --chown=dockremap:dockremap ./script.sh ./entrypoint.sh

RUN apk add --no-cache bash \
    curl \
    jq \
    wget \
    aws-cli && \
    chown -R dockremap:dockremap ./ && \
    chown dockremap:dockremap /usr/bin/aws && \
    chmod +x ./entrypoint.sh

USER dockremap

ENTRYPOINT ["./entrypoint.sh"]
