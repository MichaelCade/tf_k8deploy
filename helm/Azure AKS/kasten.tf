resource "kubernetes_namespace" "kasten" {
  metadata {
    name = "kasten-io"
  }
}

resource "helm_release" "kasten" {
  name       = "k10"
  repository = "https://charts.kasten.io"
  chart      = "k10"
  namespace  = kubernetes_namespace.kasten.metadata[0].name

  set {
    name  = "externalGateway.create"
    value = "true"
  }

  set {
    name  = "auth.tokenAuth.enabled"
    value = "true"
  }

}