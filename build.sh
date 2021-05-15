#!/bin/bash
ARTIFACT_NAME=trivy-k8s-webhook_0.0.1_Linux_64bit.tar.gz
TAG_NAME=linuxacademycontent/trivy-k8s-webhook:0.0.1

rm -rf build
mkdir build

CGO_ENABLED=0 GOOS=linux go build -a -o build/trivy-k8s-webhook .

cp -R certs build/

cd build
tar -zcvf $ARTIFACT_NAME *

cd ..
docker build --no-cache -t $TAG_NAME .
docker push $TAG_NAME
docker build -t linuxacademycontent/trivy-k8s-webhook .
docker push linuxacademycontent/trivy-k8s-webhook
