FROM golang:1.16.4
WORKDIR /go/src/acloud.guru/cks/trivy-k8s-webhook
COPY trivy-k8s-webhook.go go.mod .
RUN CGO_ENABLED=0 GOOS=linux go build -a -o trivy-k8s-webhook .

FROM aquasec/trivy:0.17.2
COPY --from=0 /go/src/acloud.guru/cks/trivy-k8s-webhook/trivy-k8s-webhook /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/trivy-k8s-webhook"]
