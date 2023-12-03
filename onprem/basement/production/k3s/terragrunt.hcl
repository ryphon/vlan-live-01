# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "/home/dx/github/k3s-terraform//."
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  k3s_url = "k8s.lab"
  vip = "10.2.0.1"
  workers = {
    tf-k3s-worker-a = {
      name = "tf-k3s-worker-a"
      vm_id = 5001
      sockets = 2
      cpu_cores = 6
      disk_size = 32
      memory = "24576"
    }

    tf-k3s-worker-b = {
      name = "tf-k3s-worker-b"
      vm_id = 5002
      sockets = 2
      cpu_cores = 6
      disk_size = 32
      memory = "24576"
    }

    tf-k3s-worker-c = {
      name = "tf-k3s-worker-c"
      vm_id = 5003
      sockets = 2
      cpu_cores = 6
      disk_size = 32
      memory = "24576"
    }
  }

  controllers = {
    tf-k3s-controller-a = {
      name = "tf-k3s-controller-a"
      vm_id = 4001
      sockets = 1
      cpu_cores = 4
      disk_size = 32
      memory = "6144"
    }

    tf-k3s-controller-b = {
      name = "tf-k3s-controller-b"
      vm_id = 4002
      sockets = 1
      cpu_cores = 4
      disk_size = 32
      memory = "6144"
    }

    tf-k3s-controller-c = {
      name = "tf-k3s-controller-c"
      vm_id = 4003
      sockets = 1
      cpu_cores = 4
      disk_size = 32
      memory = "6144"
    }
  }
}
