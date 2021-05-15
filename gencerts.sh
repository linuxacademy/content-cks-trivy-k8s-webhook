#!/bin/bash
rm -rf certs
mkdir certs
cd certs

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -key ca.key -sha256 -days 36500 -subj "/OU=ACG/CN=CKS CA" -out ca.crt

openssl genrsa -out trivy-k8s-webhook.key 2048

openssl req -new -sha256 -key trivy-k8s-webhook.key -subj "/CN=acg.trivy.k8s.webhook" -out trivy-k8s-webhook.csr

cat << EOF > extfile.cnf
keyUsage = critical, digitalSignature, keyEncipherment
basicConstraints = critical, CA:FALSE
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = DNS:acg.trivy.k8s.webhook,DNS:trivyhook.trivyk8swebhook.svc.cluster.local,DNS:localhost,IP:127.0.0.1
EOF

openssl x509 -req -in trivy-k8s-webhook.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out trivy-k8s-webhook.crt -days 36500 -sha256 -extfile extfile.cnf

openssl genrsa -out api-server-client.key 2048

openssl req -new -sha256 -key api-server-client.key -subj "/CN=api-server" -out api-server-client.csr

openssl x509 -req -in api-server-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out api-server-client.crt -days 36500 -sha256
