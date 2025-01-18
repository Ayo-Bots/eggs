#!/bin/bash

# Navigate to the container's working directory.
cd /home/container || { echo "Failed to change directory to /home/container"; exit 1; }

# Extract and export the internal Docker IP address.
export INTERNAL_IP=$(ip route get 1 | awk '{print $NF; exit}')
if [[ -z "$INTERNAL_IP" ]]; then
  echo "Failed to retrieve INTERNAL_IP. Exiting."
  exit 1
fi
echo "Internal Docker IP: $INTERNAL_IP"

# Print the Bun version to verify its availability.
if ! command -v bun &>/dev/null; then
  echo "Bun is not installed or not in PATH. Exiting."
  exit 1
fi
bun -v

# Replace placeholders {{VAR}} with their corresponding environment variables in the STARTUP command.
if [[ -z "$STARTUP" ]]; then
  echo "STARTUP variable is not set. Exiting."
  exit 1
fi

MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e "Executing: /home/container$ ${MODIFIED_STARTUP}"

# Execute the server start command.
eval "${MODIFIED_STARTUP}" || { echo "Failed to execute the startup command. Exiting."; exit 1; }

