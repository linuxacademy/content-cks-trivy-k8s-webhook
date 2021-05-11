FROM nginx:1.19.10

RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list && apt-get update && apt-get install -y trivy
