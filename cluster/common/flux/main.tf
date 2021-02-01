locals {
    namespace = "flux"
    ssh_secret_name = "flux-ssh"
}

data "terraform_remote_state" "persistent_resources" {
  backend = "azurerm"
  config = {
    resource_group_name     = "ngenic-aks-tfstate-rg"
    storage_account_name    = "ngenicakstfstate"
    container_name          = "tfstate"
    key                     = "prod.persistent-resources.tfstate"
  }
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
    name = "logFormat"
    value = "json"
    type = "string"
  }

  set {
    name = "podLabels.aadpodidbinding"
    value = "${var.pod_identity_selector}"
    type = "string"
  }

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
    name  = "syncGarbageCollection.enabled"
    value = var.gc_enabled
    type = "string"
  }

  set {
    name  = "serviceAccount.name"
    value = "flux"
    type = "string"
  }

  set {
    name  = "extraVolumes[0].name"
    value = "secrets-store-inline"
    type  = "string"
  }

  set {
    name  = "extraVolumes[0].csi.driver"
    value = "secrets-store.csi.k8s.io"
    type  = "string"
  }

  set {
    name  = "extraVolumes[0].csi.readOnly"
    value = true
  }

  set {
    name  = "extraVolumes[0].csi.volumeAttributes.secretProviderClass"
    value = var.keyvault_spc_name
    type = "string"
  }

  set {
    name  = "extraVolumeMounts[0].name"
    value = "secrets-store-inline"
    type  = "string"
  }

  set {
    name  = "extraVolumeMounts[0].mountPath"
    value = "/etc/kubernetes/"
    type  = "string"
  }

  set {
    name  = "extraVolumeMounts[0].readOnly"
    value = true
  }

  set {
    name = "dashboards.enabled"
    value = true
  }

  set {
    name = "dashboards.namespace"
    value = "monitoring"
    type = "string"
  }

  set {
    name = "registry.includeImage[0]"
    value = "${data.terraform_remote_state.persistent_resources.outputs.acr_login_server}/*"
    type = "string"
  }

  set {
    name = "registry.dockercfg.enabled"
    value = true
  }

  set {
    name = "registry.dockercfg.secretName"
    value = "docker-config-json"
    type = "string"
  }

  set {
    name = "registry.dockercfg.configFileName"
    value = "/dockercfg/docker-config.json"
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
    name = "logFormat"
    value = "json"
    type = "string"
  }  
  
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