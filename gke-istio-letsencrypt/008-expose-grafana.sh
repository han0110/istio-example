#!/bin/bash

source .env

cat <<EOF | kubectl apply -n ${ISTIO_NAMESPACE} -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
spec:
  hosts:
  - "grafana.${DNS_NAME}"
  gateways:
  - public-gateway.istio-system.svc.cluster.local
  http:
  - route:
    - destination:
        host: grafana
    timeout: 30s
EOF
