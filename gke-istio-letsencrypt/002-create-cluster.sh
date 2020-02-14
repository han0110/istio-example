#!/bin/bash

source .env

K8S_VERSION=$(gcloud container get-server-config --format=json | jq -r '.validMasterVersions[0]')

gcloud container clusters create ${CLUSTER_NAME} \
    --cluster-version=${K8S_VERSION} \
    --zone=${ZONE} \
    --num-nodes=3 \
    --machine-type=${MACHINE_TYPE} \
    --preemptible \
    --disk-size=50 \
    --enable-autorepair \
    --scopes=gke-default

kubectl get nodes -o wide ${CLUSTER_NAME} --zone=${ZONE}

kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
    --clusterrole=cluster-admin \
    --user="$(gcloud config get-value core/account)"

kubectl get nodes -o wide
