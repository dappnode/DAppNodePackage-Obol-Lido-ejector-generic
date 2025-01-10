
ARG DV_EXIT_VERSION
FROM obolnetwork/lido-dv-exit:${DV_EXIT_VERSION}

ARG STAKER_SCRIPTS_VERSION
ENV STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ARG NETWORK
ENV NETWORK=${NETWORK}

USER root

ADD ${STAKER_SCRIPTS_URL}/dvt_lsd_tools.sh /etc/profile.d/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/charon/.charon \
    apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +rx /etc/profile.d/dvt_lsd_tools.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]