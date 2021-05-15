package main

import (
    "fmt"
    "net/http"
    "os/exec"
    "encoding/json"
    "log"
)

type ImageWebhookReq struct {
    Spec Spec `json:"spec"`
}

type Spec struct {
    Containers []Container `json:"containers"`
}

type Container struct {
    Image string `json:"image"`
}

func scan(w http.ResponseWriter, req *http.Request) {

    var reqData ImageWebhookReq
    erro := json.NewDecoder(req.Body).Decode(&reqData)

    if erro != nil {
        http.Error(w, erro.Error(), http.StatusBadRequest)
        return
    }

    var passed bool
    passed = true
    var reasons []string

    for i, container := range reqData.Spec.Containers {
        image := container.Image
        log.Printf("Scanning image %v %v", i, image)
        if trivyScanImage(image) {
            log.Printf("Scanning passed for image %v %v", i, image)
        } else {
            passed = false
            reasons = append(reasons, image)
            log.Printf("Scanning failed for image %v %v", i, image)
        }
    }
    message := ""
    if !passed {
        message = fmt.Sprintf("Image(s) contain serious vulnerabilities: %v", reasons)
    }
    output := fmt.Sprintf("{\"apiVersion\": \"imagepolicy.k8s.io/v1alpha1\",\"kind\": \"ImageReview\",\"status\": {\"allowed\": %v,\"reason\": \"%v\"}}", passed, message)
    log.Printf("Response %v", output)
    fmt.Fprintf(w, output)
}

func trivyScanImage(image string) bool {
    cmd := exec.Command("trivy", "image", "--severity=CRITICAL", "--exit-code=1", image)
    out, err := cmd.CombinedOutput()
    log.Printf("Output: %v", string(out))
    log.Printf("Error: %v", err)
    return err == nil
}

func headers(w http.ResponseWriter, req *http.Request) {

    for name, headers := range req.Header {
        for _, h := range headers {
            fmt.Fprintf(w, "%v: %v\n", name, h)
        }
    }
}

func main() {

    http.HandleFunc("/scan", scan)
    http.HandleFunc("/headers", headers)

    log.Fatal(http.ListenAndServeTLS(":8090", "certs/trivy-k8s-webhook.crt", "certs/trivy-k8s-webhook.key", nil))
}
