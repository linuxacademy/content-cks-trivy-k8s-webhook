# trivy-k8s-webhook

This is a webhook application designed to work with the Kubernetes ImagePolicyWebhook admission controller. It scans the provided images with [Trivy](https://github.com/aquasecurity/trivy) and approves creation of the workload only if Trivy does not detect any HIGH- or CRITICAL-severity vulnerabilities.

The webhook application listens on port `8090`.

## Certificates

ImagePolicyWebhook requires https. As such, you must supply valid certificates in order to run this code. This application looks for the following certificate files:

- Server certificate - `certs/trivy-k8s-webhook.crt`
- Certificate key - `certs/trivy-k8s-webhook.key`
