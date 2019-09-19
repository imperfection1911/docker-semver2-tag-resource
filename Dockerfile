FROM gliderlabs/alpine:3.3
COPY assets/* /opt/resource/
RUN apk update && apk add --no-cache bash git jq redis
RUN git config --global user.name "Concourse CI" \ 
    && git config --global user.email "git.concourse-ci@localhost" \
    && chmod +x /opt/resource/* \
    && rm -rf /tmp/*
