#!/bin/bash

source .env

kubectl create namespace ${ISTIO_NAMESPACE}

helm repo add istio.io "https://storage.googleapis.com/istio-release/releases/${ISTIO_VERSION}/charts" && helm repo update

helm upgrade -i istio-init \
  --namespace ${ISTIO_NAMESPACE} \
  --wait \
  istio.io/istio-init

kubectl -n ${ISTIO_NAMESPACE} create secret generic grafana \
    --from-literal=username=admin \
    --from-literal=passphrase=${GRAFANA_PASSWORD}

kubectl -n ${ISTIO_NAMESPACE} create secret generic kiali \
    --from-literal=username=admin \
    --from-literal=passphrase=${KIALI_PASSWORD}

GATEWAY_IP=$(gcloud compute addresses describe ${CLUSTER_NAME} --region=${REGION} --format=json | jq -r '.address')

cat <<EOF | helm upgrade --install istio istio.io/istio --namespace=${ISTIO_NAMESPACE} -f -
# ingress configuration
gateways:
  enabled: true
  istio-ingressgateway:
    type: LoadBalancer
    loadBalancerIP: ${GATEWAY_IP}
    autoscaleEnabled: true
    autoscaleMax: 2

# common settings
global:
  # sidecar settings
  proxy:
    resources:
      requests:
        cpu: 10m
        memory: 64Mi
      limits:
        cpu: 2000m
        memory: 256Mi
  controlPlaneSecurityEnabled: false
  mtls:
    enabled: false
  useMCP: true

# pilot configuration
pilot:
  enabled: true
  autoscaleEnabled: true
  sidecar: true
  resources:
    requests:
      cpu: 10m
      memory: 128Mi

# sidecar-injector webhook configuration
sidecarInjectorWebhook:
  enabled: true

# security configuration
security:
  enabled: true

# galley configuration
galley:
  enabled: true

# mixer configuration
mixer:
  policy:
    enabled: false
    replicaCount: 1
    autoscaleEnabled: true
  telemetry:
    enabled: true
    replicaCount: 1
    autoscaleEnabled: true
  resources:
    requests:
      cpu: 10m
      memory: 128Mi

# addon prometheus configuration
prometheus:
  enabled: true
  scrapeInterval: 5s

# addon jaeger tracing configuration
tracing:
  enabled: true

# addon grafana configuration
grafana:
  enabled: true
  security:
    enabled: true

kiali:
  enabled: true
  dashboard:
    grafanaURL: http://grafana:3000"
EOF
