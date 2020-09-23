locals {
    namespace = "flux"
    ssh_secret_name = "flux-ssh"
}

resource "kubernetes_namespace" "gitops_namespace" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "flux_helm" {
  count = var.enable_flux ? 1 : 0

  name              = "gitops-flux"
  repository        = "https://charts.fluxcd.io" 
  chart             = "flux"
  version           = "1.5.0"

  namespace         = kubernetes_namespace.gitops_namespace.metadata.0.name

  set {
    name  = "image.repository"
    value = var.flux_image_repository
    type = "string"
  }

  set {
    name  = "image.tag"
    value = var.flux_image_tag
    type = "string"
  }

  set {
    name  = "git.url"
    value = var.gitops_ssh_url
    type = "string"
  }

  set {
    name  = "git.branch"
    value = var.gitops_url_branch
    type = "string"
  } 

  set {
    name  = "git.secretName"
    value = local.ssh_secret_name
    type = "string"
  }

  set {
    name  = "git.path"
    value = var.gitops_path
    type = "string"
  }

  set {
    name  = "git.pollInterval"
    value = var.gitops_poll_interval
    type = "string"
  }

  set {
    name  = "git.label"
    value = var.gitops_label
    type = "string"
  }

  set {
    name  = "registry.acr.enabled"
    value = var.acr_enabled
    type = "string"
  }

  set {
    name  = "syncGarbageCollection.enabled"
    value = var.gc_enabled
    type = "string"
  }

  set {
    name  = "serviceAccount.name"
    value = "flux"
    type = "string"
  }
}

resource "helm_release" "flux_helm_operator" {
  count = var.enable_flux && var.enable_helm_operator ? 1 : 0

  name              = "gitops-flux-helm-operator"
  repository        = "https://charts.fluxcd.io" 
  chart             = "helm-operator"
  version           = "1.2.0"

  namespace         = kubernetes_namespace.gitops_namespace.metadata.0.name

  set {
    name  = "helm.versions"
    value = "v3"
    type = "string"
  }

  set {
    name = "git.ssh.secretName"
    value = local.ssh_secret_name
    type = "string"
  }
}

resource "kubernetes_secret" "gitops_ssh_secret" {
  metadata {
    name = local.ssh_secret_name
    namespace = kubernetes_namespace.gitops_namespace.metadata.0.name
  }

  data = {
    identity = file(var.gitops_ssh_key_path)
  }
}