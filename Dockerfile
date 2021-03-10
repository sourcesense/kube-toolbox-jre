FROM alpine:3.12.4 as curl

WORKDIR /

RUN apk add curl



FROM curl as kubectl-downloader

# Can get latest via:
# curl -L -s https://dl.k8s.io/release/stable.txt
ARG k8s_version=v1.20.2
ARG OS=${TARGETOS:-linux}
ARG ARCH=${TARGETARCH:-amd64}

RUN curl -LO "https://dl.k8s.io/release/$k8s_version/bin/$OS/$ARCH/kubectl"

RUN chmod 0755 /kubectl




FROM curl as helm-downloader

ARG helm_version="v3.5.1"
ARG OS=${TARGETOS:-linux}
ARG ARCH=${TARGETARCH:-amd64}

RUN curl -LO "https://get.helm.sh/helm-$helm_version-$OS-$ARCH.tar.gz"

RUN tar xvzf "helm-$helm_version-$OS-$ARCH.tar.gz"

RUN mv $OS-$ARCH/helm /usr/local/bin/helm

RUN chmod 0755 /usr/local/bin/helm



FROM curl as yq-downloader

ARG OS=${TARGETOS:-linux}
ARG ARCH=${TARGETARCH:-amd64}
ARG YQ_VERSION="v4.6.0"
ARG YQ_BINARY="yq_${OS}_$ARCH"
RUN wget "https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_BINARY" -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq



FROM adoptopenjdk/openjdk11:alpine-jre

COPY --from=yq-downloader --chown=root:root /usr/local/bin/yq /usr/local/bin/yq

COPY --from=kubectl-downloader --chown=root:root /kubectl /usr/local/bin/kubectl

COPY --from=helm-downloader --chown=root:root /usr/local/bin/helm /usr/local/bin/helm


