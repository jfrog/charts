# Define the nginx Deployment
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = var.nginx_replicas

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:${var.nginx_version}"
          name  = "nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Define the nginx Service
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

data "kubernetes_service" "nginx_service" {
  metadata {
    name = kubernetes_service.nginx.metadata.0.name
  }
}

output "nginx_service_cluster_ip" {
  value = data.kubernetes_service.nginx_service.spec.0.cluster_ip
}

output "nginx_service_external_ip" {
  value = data.kubernetes_service.nginx_service.status[0].load_balancer[0].ingress[0].ip
}
