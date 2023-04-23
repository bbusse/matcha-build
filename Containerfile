ARG IMAGE_VERSION=edge
ARG IMAGE_VERSION_GOLANG=1.20-alpine
ARG GOPATH=/usr/local/go
FROM alpine:${IMAGE_VERSION}
LABEL maintainer="Björn Busse <bj.rn@baerlin.eu>"
LABEL org.opencontainers.image.source https://github.com/bbusse/matcha-build

ENV USER="build" \
    PACKAGES="git npm xz" \
    PATH="/usr/local/go/bin:${PATH}"

COPY --from=golang:1.20-alpine $GOPATH $GOPATH

# Add application user and application
RUN addgroup -S $USER && adduser -S $USER -G $USER \
    && apk add --no-cache ${PACKAGES} \
    && cd /tmp/ && git clone https://github.com/emersion/matcha \
    && cd /tmp/matcha/cmd/matcha && go build \
    && cd /tmp/matcha/public && npm install \
    && cd /tmp/matcha && tar cfJ /tmp/matcha.tar.xz cmd/matcha public/ \
    && tar cfJ /tmp/matcha-htdocs.tar.xz public/

USER $USER

# Add entrypoint
COPY matcha-build /usr/local/bin/
ENTRYPOINT ["matcha-build"]
