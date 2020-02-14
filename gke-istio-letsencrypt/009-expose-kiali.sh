#!/bin/bash

source .env

cat <<EOF | kubectl apply -n ${ISTIO_NAMESPACE} -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kiali
spec:
  hosts:
  - "kiali.${DNS_NAME}"
  gateways:
  - public-gateway.istio-system.svc.cluster.local
  http:
  - route:
    - destination:
        host: kiali
        port:
          number: 20001
    timeout: 30s
EOF
