#!/bin/bash

echo "[INFO - entrypoint] NETWORK is: $NETWORK"

if [ -z "$CHARON_TO_EXIT_NUMBER" ] || ! [[ "$CHARON_TO_EXIT_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "[ERROR - entrypoint] CHARON_TO_EXIT_NUMBER is not defined or is not a number. Please set the correct value in the config tab."
    exit 0
fi

CHARON_DIR=/charon/charon${CHARON_TO_EXIT_NUMBER}
EXIT_PATH=/exitmessages/charon${CHARON_TO_EXIT_NUMBER}

mkdir -p $EXIT_PATH

if [ -z "$ CHARON_DIR" ] || [ ! -d "$CHARON_DIR" ]; then
    echo "[ERROR - entrypoint] Charon directory is empty or does not exist. Please upload the Obol backup to this package."
    echo "[INFO - entrypoint] This service will be running for 1h to allow you to upload the backup."
    sleep 1h
    exit 0
fi

# Call the function and store its return value in a variable
BEACON_API_URL="$(get_beacon_api_url_from_global_env "$NETWORK")"
echo "[INFO - entrypoint] Beacon API URL: ${BEACON_API_URL}"
export BEACON_API_URL

echo "[INFO - entrypoint] Starting Lido DV Exit..."
exec /usr/local/bin/lido-dv-exit run \
    --beacon-node-url ${BEACON_API_URL} \
    --charon-runtime-dir ${CHARON_DIR} \
    --ejector-exit-path ${EXIT_PATH} \
    --exit-epoch ${EXIT_EPOCH} \
    --log-level ${LOG_LEVEL} \
    --validator-query-chunk-size ${VALIDATOR_QUERY_CHUNK_SIZE}