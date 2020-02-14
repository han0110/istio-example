#!/bin/bash

source .env

cat <<EOF | kubectl apply -n ${ISTIO_NAMESPACE} -f -
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${LETSENCRYPT_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        clouddns:
          project: ${PROJECT_ID}
          serviceAccountSecretRef:
            name: cert-manager-credentials
            key: gcp-dns-admin.json
      selector: {}
EOF

cat <<EOF | kubectl apply -n ${ISTIO_NAMESPACE} -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: istio-gateway
spec:
  secretName: istio-ingressgateway-certs
  issuerRef:
    name: letsencrypt-prod
  dnsNames:
  - "*.${DNS_NAME}"
  - "${DNS_NAME}"
EOF

kubectl -n ${ISTIO_NAMESPACE} delete pods -l istio=ingressgateway
