resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

  depends_on = [module.eks_cluster]
}

resource "github_repository_deploy_key" "flux" {
  title      = "gitops-hashicups"
  repository = var.repository_name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository = var.repository_name
  file       = data.flux_install.flux.path
  content    = data.flux_install.flux.content
  branch     = var.repository_branch
}

resource "github_repository_file" "sync" {
  repository = var.repository_name
  file       = data.flux_sync.flux.path
  content    = data.flux_sync.flux.content
  branch     = var.repository_branch
}

resource "github_repository_file" "kustomize" {
  repository = var.repository_name
  file       = data.flux_sync.flux.kustomize_path
  content    = data.flux_sync.flux.kustomize_content
  branch     = var.repository_branch
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubernetes_secret" "flux" {
  metadata {
    name      = data.flux_sync.flux.secret
    namespace = data.flux_sync.flux.namespace
  }

  data = {
    identity       = tls_private_key.flux.private_key_pem
    "identity.pub" = tls_private_key.flux.public_key_pem
    known_hosts    = local.known_hosts
  }

  depends_on = [kubectl_manifest.install, module.eks_cluster]
}
