locals {
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
