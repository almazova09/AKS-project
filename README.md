# Kubernetes + AKS + Terraform + CI/CD + ArgoCD

This documentation provides a full end‑to‑end guide for:

* Automating creation of an AKS cluster with Terraform
* Building & pushing Docker images to Azure Container Registry (ACR)
* Deploying Node.js web and API apps + MySQL using Helm charts
* Creating Kubernetes manifests (deployments, services, configmaps, secrets, HPA)
* Wiring CI/CD using Jenkins, GitHub Actions, ArgoCD

Repos:

* web: [https://github.com/almazova09/web-project](https://github.com/almazova09/web-project)
* api: [https://github.com/almazova09/api-project](https://github.com/almazova09/api-project)
* mysql: [https://github.com/almazova09/mysql-project](https://github.com/almazova09/mysql-project)

---

# 1. Azure Setup Commands

## Export Azure Service Principal Credentials (for Terraform)

```
export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<YOUR_TENANT_ID>"
export ARM_CLIENT_ID="<YOUR_CLIENT_ID>"
export ARM_CLIENT_SECRET="<YOUR_CLIENT_SECRET>"
```

## Re‑authenticate Azure CLI

```bash
az logout
az login
```

## Login & Subscription

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

## Create Resource Group

```bash
az group create -n aks-rg -l eastus
```

---

# 2. Azure Container Registry (ACR)

## Create ACR

```bash
az acr create --resource-group aks-rg --name myprivateregistry15 --sku Premium
```

## Login to ACR

```bash
az acr login --name myprivateregistry15
```

## List Repositories

```bash
az acr repository list --name myprivateregistry15 --output table
```

## Environment Variable

```bash
export ACR_NAME=myprivateregistry15
```

---

# 3. Create Image Pull Secret for Kubernetes

```bash
kubectl create secret docker-registry acr-auth \
  --docker-server=${ACR_NAME}.azurecr.io \
  --docker-username=$(az acr credential show -n $ACR_NAME --query username -o tsv) \
  --docker-password=$(az acr credential show -n $ACR_NAME --query passwords[0].value -o tsv)
```

---

# 4. Dockerfile for Node.js (Web & API)

```dockerfile
FROM node:18 AS builder
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install
COPY app.js ./
COPY bin ./bin
COPY routes ./routes
COPY views ./views
COPY public ./public
FROM node:18-slim
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app .
EXPOSE 3000
CMD ["npm","start"]
```

```dockerfile
FROM node:18
WORKDIR /usr/src/app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3001
CMD ["npm","start"]
```


(Do NOT include environment variables — use ConfigMap + Secret.)

## Build & Push Images

```bash
docker build -t ${ACR_NAME}.azurecr.io/web:v1 .
docker push ${ACR_NAME}.azurecr.io/web:v1

docker build -t ${ACR_NAME}.azurecr.io/api:v1 .
docker push ${ACR_NAME}.azurecr.io/api:v1
```

---

# 5. Terraform for AKS

(Use `aks-project` repo)

Basic structure:

```
terraform /
  main.tf
  outputs.tf
  provider.tf
  sg.tf
  variables.tf
  outputs.tf
```

## Initialize & Deploy

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Get AKS Credentials

```bash
az aks get-credentials --resource-group aks-rg --name aks-cluster
```

---

# 6. Helm Charts

```bash
├── api
│   ├── Chart.yaml
│   ├── templates
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── hpa.yaml
│   │   ├── secret.yaml
│   │   └── service.yaml
│   └── values.yaml
├── mysql
│   ├── Chart.yaml
│   ├── templates
│   │   ├── secret.yaml
│   │   ├── service.yaml
│   │   └── statefulset.yaml
│   └── values.yaml
└── web
    ├── Chart.yaml
    ├── LICENSE.txt
    ├── templates
    │   ├── configmap.yaml
    │   ├── deployment.yaml
    │   ├── hpa.yaml
    │   ├── secret.yaml
    │   └── service.yaml
    └── values.yaml
```

Each chart includes:

* Deployment.yaml (with probes, resources, rolling update)
* Service.yaml (LoadBalancer)
* ConfigMap.yaml
* Secret.yaml
* HPA.yaml

## Install Charts

```bash
helm install web ./web
helm install api ./api
helm install mysql ./mysql
```

## Upgrade

```bash
helm upgrade web ./web
```

---

# 7. Kubernetes Settings

## Liveness & Readiness Example

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Resource Requests

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

## Rolling Update

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

## HPA

```bash
kubectl autoscale deployment web --cpu-percent=50 --min=1 --max=5
```

---
