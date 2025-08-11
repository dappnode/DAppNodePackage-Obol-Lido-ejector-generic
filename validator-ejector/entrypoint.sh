#!/bin/sh

# If OPERATOR_ID is not defined or is not a number, exit 0 to avoid restart,
# telling the user to set the correct value
if [ -z "$OPERATOR_ID" ] || ! echo "$OPERATOR_ID" | grep -qE '^[0-9]+$'; then
    echo "[ERROR - entrypoint] OPERATOR_ID is not defined or is not a number. Please set the correct value in the config tab."
    exit 0
fi

if [ -z "$CHARON_TO_EXIT_NUMBER" ] || ! echo "$CHARON_TO_EXIT_NUMBER" | grep -qE '^[0-9]+$'; then
    echo "[ERROR - entrypoint] CHARON_TO_EXIT_NUMBER is not defined or is not a number. Please set the correct value in the config tab."
    exit 0
fi

# Just to illustrate that NETWORK is accessible:
echo "[INFO - entrypoint] NETWORK is: $NETWORK"

# Example: set LOCATOR_ADDRESS, HASH_CONSENSUS_CONTRACT, DEFAULT_ORACLE_ADDRESSES_ALLOWLIST
# per network if needed:
case "$NETWORK" in
  "mainnet")
    export LOCATOR_ADDRESS="0xC1d0b3DE6792Bf6b4b37EccdcC24e45978Cfd2Eb"
    export HASH_CONSENSUS_CONTRACT="0x7FaDB6358950c5fAA66Cb5EB8eE5147De3df355a"
    export DEFAULT_ORACLE_ADDRESSES_ALLOWLIST='["0x140Bd8FbDc884f48dA7cb1c09bE8A2fAdfea776E","0x4118DAD7f348A4063bD15786c299De2f3B1333F3","0x404335BcE530400a5814375E7Ec1FB55fAff3eA2","0x946D3b081ed19173dC83Cd974fC69e1e760B7d78","0x007DE4a5F7bc37E2F26c0cb2E8A95006EE9B89b5","0xc79F702202E3A6B0B6310B537E786B9ACAA19BAf","0x61c91ECd902EB56e314bB2D5c5C07785444Ea1c8","0xe57B3792aDCc5da47EF4fF588883F0ee0c9835C9","0x73181107c8D9ED4ce0bbeF7A0b4ccf3320C41d12"]'
    ;;
  "holesky")
    export LOCATOR_ADDRESS="0x28FAB2059C713A7F9D8c86Db49f9bb0e96Af1ef8"
    export HASH_CONSENSUS_CONTRACT="0xe77Cf1A027d7C10Ee6bb7Ede5E922a181FF40E8f"
    export DEFAULT_ORACLE_ADDRESSES_ALLOWLIST='["0x12A1D74F8697b9f4F1eEBb0a9d0FB6a751366399","0xD892c09b556b547c80B7d8c8cB8d75bf541B2284","0xf7aE520e99ed3C41180B5E12681d31Aa7302E4e5","0x31fa51343297FFce0CC1E67a50B2D3428057D1b1","0x81E411f1BFDa43493D7994F82fb61A415F6b8Fd4","0x4c75FA734a39f3a21C57e583c1c29942F021C6B7","0xD3b1e36A372Ca250eefF61f90E833Ca070559970","0xF0F23944EfC5A63c53632C571E7377b85d5E6B6f","0xb29dD2f6672C0DFF2d2f173087739A42877A5172","0xfe43A8B0b481Ae9fB1862d31826532047d2d538c"]'
    ;;
  *)
    echo "[ERROR - entrypoint] Unknown value or unsupported for NETWORK. Please confirm that the value is correct."
    exit 1
    ;;
esac

# To use staker scripts
# shellcheck disable=SC1091
. /etc/profile

# Retrieve the beacon and execution URLs based on NETWORK
# (Uses the helper functions defined at the top)
_BEACON_NODE_API="$(get_beacon_api_url_from_global_env "$NETWORK")"
_EXECUTION_NODE_API="$(get_execution_rpc_api_url_from_global_env "$NETWORK")"

# Write the default Oracle addresses allowlist to the configured path
echo "$DEFAULT_ORACLE_ADDRESSES_ALLOWLIST" >"$ORACLE_LIST_FILE_PATH"

# Prepare additional environment variables
EXIT_MESSAGES_ROOT="/exitmessages"
CHARON_ID="charon${CHARON_TO_EXIT_NUMBER}"

export MESSAGES_LOCATION="${EXIT_MESSAGES_ROOT}/${CHARON_ID}"
export EXECUTION_NODE="${_EXECUTION_NODE_API}"
export CONSENSUS_NODE="${_BEACON_NODE_API}"

# Run the script to retrieve the oracle list from the contract (written to the file $ORACLE_LIST_FILE_PATH)
# Skip error as the default list is already written to the file
node "${ORACLE_LIST_RETRIEVER_PATH}" || true

export ORACLE_ADDRESSES_ALLOWLIST="$(cat "$ORACLE_LIST_FILE_PATH")"

# Make sure messages directory is present
if [ ! -d "$MESSAGES_LOCATION" ]; then
    echo "[INFO - entrypoint] Messages directory does not exist. Waiting until the lido-dv-exit service creates it..."
    inotifywait --event create --include "${CHARON_ID}" "${EXIT_MESSAGES_ROOT}"
else
    echo "[INFO - entrypoint] Messages directory exists"
fi

echo "[INFO - entrypoint] Starting the lido-dv-exit service..."
cd /app
exec yarn start
