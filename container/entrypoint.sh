#!/bin/bash

# Enable debugging
set -x

# Replace the placeholders with the set environment variables
sed -i -e "s/OPENSEARCH_URL/$opensearch_url/g"\
 -e "s/OPENSEARCH_PORT/$opensearch_port/g"\
 -e "s/OPENSEARCH_PROTOCOL/$opensearch_protocol/g"\
 -e "s/OPENSEARCH_USERNAME/$opensearch_username/g"\
 -e "s/OPENSEARCH_PASSWORD/$opensearch_password/g"\
 /etc/filebeat/filebeat.yml

# Start Wazuh and Filebeat
/var/ossec/bin/wazuh-control start
filebeat &&

# Hang
tail -f /dev/null