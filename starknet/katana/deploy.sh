#!/bin/bash

# Load the addresses from the deployed-contracts.txt file
declare -A class_hashes
declare -A addresses

while IFS= read -r line; do
    contract_name=$(echo "$line" | cut -d ':' -f 1 | xargs)
    class_hash=$(echo "$line" | cut -d ' ' -f 2 | xargs)

    class_hashes["$contract_name"]=$class_hash
done < katana/declared-classes.txt

messages_proxy_class_hash=${class_hashes["messages-proxy"]}
headers_store_class_hash=${class_hashes["headers-store"]}
fact_registry_class_hash=${class_hashes["fact-registry"]}

# Debug: Print the class_hashes
echo "Fact Registry Class hash: $fact_registry_class_hash"
echo "Headers Store Class hash: $headers_store_class_hash"
echo "Messages Proxy Class hash: $messages_proxy_class_hash"

# Retrieve the L1_MESSAGE_SENDER_ADDRESS from the environment variables
l1_message_sender_address=${L1_MESSAGE_SENDER_ADDRESS}
owner_address=${OWNER_ADDRESS}

# Check if the L1_MESSAGE_SENDER_ADDRESS environment variable is set
if [ -z "$l1_message_sender_address" ]; then
    echo "Error: L1_MESSAGE_SENDER_ADDRESS environment variable is not set."
    exit 1
fi

# Remove existing declared-classes.txt file if it exists
rm -f katana/deployed-contracts.txt

# Perform Deployment
# Message Proxy Deployment
echo "Deploying messages-proxy with L1_MESSAGE_SENDER_ADDRESS and owner address..."
output=$(starkli deploy "$messages_proxy_class_hash" "$l1_message_sender_address" "$owner_address" --salt 0x1 -w)
echo "messages-proxy: $output" >> katana/deployed-contracts.txt
messages_proxy=$output
echo "Messages Proxy address: $messages_proxy"
echo "Deployment address for messages-proxy saved to deployed-contracts.txt"


# Header Store Deployment
echo "Deploying headers-store with messages-proxy address..."
output=$(starkli deploy "$headers_store_class_hash" "$messages_proxy" "$owner_address" --salt 0x1 -w)
echo "headers-store: $output" >> katana/deployed-contracts.txt
headers_store=$output
echo "Header Store address: $headers_store"
echo "Deployment address for headers-store saved to deployed-contracts.txt"

# Fact Registry Deployment
echo "Deploying fact-registry with headers-store address and owner address..."
output=$(starkli deploy "$fact_registry_class_hash" "$headers_store" "$owner_address" --salt 0x1 -w)
echo "fact-registry: $output" >> katana/deployed-contracts.txt
echo "Fact Registry address: $headers_store"åå
echo "Deployment address for fact-registry saved to deployed-contracts.txt"

echo "Deployment complete."