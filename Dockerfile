
#
# Builder
#
FROM  ghcr.io/kazan417/docker-golang123-astra as builder

ARG version="1.0.3"
#ARG plugins="git,cors,realip,expires,cache,cloudflare"
ARG enable_telemetry="false"

# process wrapper
RUN apt update
RUN apt -y install git
RUN git clone "https://github.com/caddyserver/caddy.git"
RUN cd /caddy/cmd/caddy/ && go build 
#
# Final stage
#
FROM registry.astralinux.ru/astra/ubi18
LABEL maintainer "Kazantsev Mikhail <kazan417@mail.ru>"

ARG version="1.0.3"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="$enable_telemetry"
RUN apt update
RUN apt -y install \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata

# install caddy
COPY --from=builder /caddy/cmd/caddy/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy --version
#RUN /usr/bin/caddy --plugins

EXPOSE 80 443 2015
#VOLUME ./ /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

# install process wrapper
#COPY --from=builder /go/bin/parent /bin/parent

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
