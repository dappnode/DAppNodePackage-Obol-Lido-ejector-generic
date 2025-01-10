ARG EJECTOR_VERSION
FROM lidofinance/validator-ejector:${EJECTOR_VERSION}

ARG STAKER_SCRIPTS_VERSION
ENV STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

USER root

ADD ${STAKER_SCRIPTS_URL}/dvt_lsd_tools.sh /etc/profile.d/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY getOracleAddresses.js /app/dist/

RUN apk update && \
    apk add inotify-tools && \
    chmod +rx /etc/profile.d/dvt_lsd_tools.sh /usr/local/bin/entrypoint.sh



ARG NETWORK
ENV RUN_METRICS=true \
    HTTP_PORT=8989 \
    DISABLE_SECURITY_DONT_USE_IN_PRODUCTION=false \
    NETWORK=${NETWORK} \
    STAKING_MODULE_ID=2 \
    ORACLE_LIST_FILE_PATH=/allowedOracles.json \
    ORACLE_LIST_RETRIEVER_PATH=/app/dist/getOracleAddresses.js


ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]