provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "simple_time" {
  metadata {
    name = "simple-time-service"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "simple-time"
      }
    }
    template {
      metadata {
        labels = {
          app = "simple-time"
        }
      }
      spec {
        container {
          name  = "time"
          image = "yourdockerhubusername/simple-time-service:latest"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "simple_time_svc" {
  metadata {
    name = "simple-time-service"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }
  }
  spec {
    selector = {
      app = "simple-time"
    }
    port {
      port        = 80
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}
