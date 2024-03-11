# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "/home/dx/github/k3s-terraform//."
  source = "git@git.dragonfruit.dev:k8s/k3s-terraform?branch=cilium"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  k3s_url = "k8s2.lab"
  vip = "10.3.0.1"
  workers = {
    #tf-k3s2-worker-a = {
    #  name = "tf-k3s2-worker-a"
    #  vm_id = 7001
    #  sockets = 2
    #  cpu_cores = 2
    #  disk_size = 32
    #  memory = "4096"
    #}

    #tf-k3s2-worker-b = {
    #  name = "tf-k3s2-worker-b"
    #  vm_id = 7002
    #  sockets = 2
    #  cpu_cores = 2
    #  disk_size = 32
    #  memory = "4096"
    #}

    #tf-k3s2-worker-c = {
    #  name = "tf-k3s2-worker-c"
    #  vm_id = 7003
    #  sockets = 2
    #  cpu_cores = 2
    #  disk_size = 32
    #  memory = "4096"
    #}
  }

  controllers = {
    tf-k3s2-controller-a = {
      name = "tf-k3s2-controller-a"
      vm_id = 6001
      sockets = 1
      cpu_cores = 4
      disk_size = 32
      memory = "4096"
    }
  }
}
