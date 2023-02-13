resource "kubernetes_deployment" "min_app" {
  metadata {
    name = "min-app"
    labels = {
      app = "min-app"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "min-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "min-app"
        }
      }
      spec {
        container {
          image = "thstarshine/blunomy-min-app:latest"
          image_pull_policy = "Always"
          name  = "min-app"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "768Mi"
            }
            requests = {
              cpu    = "350m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 8080
            }
            failure_threshold = 3
            period_seconds = 10
            timeout_seconds = 5
          }
          startup_probe {
            http_get {
              path = "/ping"
              port = 8080
            }
            failure_threshold = 30
            period_seconds = 10
            initial_delay_seconds = 25
          }

        }

      }
    }
  }

  depends_on = [
    google_container_node_pool.blunomy_demo_nodes,
  ]
}

resource "kubernetes_service" "min_app" {
  metadata {
    name = "min-app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.min_app.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
    }

    load_balancer_source_ranges = [
      "0.0.0.0/0", # public
    ]
    type = "LoadBalancer"
  }
}
