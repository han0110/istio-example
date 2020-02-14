#!/bin/bash

source .env

gcloud dns managed-zones create \
    --dns-name=${DNS_NAME} \
    --description="Zone for ${CLUSTER_NAME}" \
    ${MANAGED_ZONE_NAME}

gcloud dns managed-zones describe ${MANAGED_ZONE_NAME}

gcloud compute addresses create ${CLUSTER_NAME} --region=${REGION}

GATEWAY_IP=$(gcloud compute addresses describe ${CLUSTER_NAME} --region=${REGION} --format=json | jq -r '.address')

gcloud dns record-sets transaction start --zone=${CLUSTER_NAME}

for SUBDOMAIN in "" "www." "*."; do
    gcloud dns record-sets transaction add \
        --zone=${ZONE} \
        --name="${SUBDOMAIN}${DNS_NAME}" \
        --ttl=300 \
        --type=A \
        ${GATEWAY_IP}
done

gcloud dns record-sets transaction execute --zone=${CLUSTER_NAME}
