terraform {
    required_providers {
        proxmox = {
            source = "bpg/proxmox"
            #version = "~> 0.2.1"
        }
        k0s = {
            source = "alessiodionisi/k0s"
            #version = "~> 0.2.1"
        }
        helm = {
            source = "hashicorp/helm"
            #version = "~> 2.11.0"
        }
    }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_ip}:8006/"
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

#provider "k0s" {}
#
#provider "helm" {
#  kubernetes {
#    config_path = "./kubeconfig"
#  }
#}
