#!/bin/bash

source .env

gcloud iam service-accounts create dns-admin \
    --display-name=dns-admin \
    --project=${PROJECT_ID}

gcloud iam service-accounts keys create ./gcp-dns-admin.json \
    --iam-account=dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
    --project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/dns.admin

kubectl create secret generic cert-manager-credentials \
    --from-file=./gcp-dns-admin.json \
    --namespace=${ISTIO_NAMESPACE}

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml

kubectl create namespace cert-manager

kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

helm repo add jetstack https://charts.jetstack.io && helm repo update

helm upgrade -i cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v0.13.0
