terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
  }
}

resource "helm_release" "mysql" {
  name       = "mysql"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = "../charts/mysql"
  dependency_update = false

  set {
    name  = "auth.rootPassword"
    value = "rootpass123"
  }
  set {
    name  = "auth.user"
    value = "kaizen"
  }
  set {
    name  = "auth.password"
    value = "Hello123!"
  }
  set {
    name  = "auth.database"
    value = "hello"
  }
}

resource "helm_release" "api" {
  name       = "api"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = "../charts/api"
  depends_on = [helm_release.mysql]

  set { name = "image.repository"; value = "myprivateregistry15.azurecr.io/api" }
  set { name = "image.tag"; value = "v1" }
  set { name = "config.DBHOST"; value = "mysql" }
  set { name = "secret.DBUSER"; value = "kaizen" }
  set { name = "secret.DBPASS"; value = "Hello123!" }
}

resource "helm_release" "web" {
  name       = "web"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = "../charts/web"
  depends_on = [helm_release.api]

  set { name = "image.repository"; value = "myprivateregistry15.azurecr.io/web" }
  set { name = "image.tag"; value = "v1" }
  set { name = "config.API_HOST"; value = "http://api.apps.svc.cluster.local:3001" }
}
