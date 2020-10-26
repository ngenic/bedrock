# container registry to download flux image
variable "flux_image_repository" {
  type    = string
  default = "docker.io/fluxcd/flux"
}

# flux version to download source from git repo and container image from the registry
variable "flux_image_tag" {
  type    = string
  default = "1.20.2"
}

variable "gitops_path" {
  type = string
}

variable "gitops_poll_interval" {
  type    = string
  default = "5m"
}

variable "gitops_label" {
  type    = string
  default = "flux-sync"
}

variable "gitops_ssh_url" {
  description = "ssh git clone repository URL with Kubernetes manifests including services which runs in the cluster. Flux monitors this repo for Kubernetes manifest additions/changes preriodiaclly and apply them in the cluster."
  type        = string
}

variable "gitops_url_branch" {
  description = "Git branch associated with the gitops_ssh_url where flux checks for the raw kubernetes yaml files to deploy to the cluster."
  type        = string
  default     = "master"
}

variable "gc_enabled" {
  type    = string
  default = "true"
}

# generate a SSH key named identity: ssh-keygen -q -N "" -f ./identity
# or use existing ssh public/private key pair
# add deploy key in gitops repo using public key with read/write access
# assign/specify private key to "gitops_ssh_key_path" variable that will be used to cretae kubernetes secret object
# flux use this key to read manifests in the git repo
variable "gitops_ssh_key_path" {
  type = string
}

variable "enable_flux" {
  type    = string
  default = "true"
}

variable "enable_helm_operator" {
  type    = string
  default = "true"
}

variable "keyvault_spc_name" {
  type    = string
  default = ""
}

variable "pod_identity_selector" {
  type    = string
  default = ""
}

variable "dependency_hook" {
  type    = string
  default = ""
}