resource "proxmox_virtual_environment_file" "workers" {
  for_each = local.workers
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.proxmox_host

  source_raw {
    data = <<EOF
#cloud-config
fqdn: ${each.key}.local
hostname: ${each.key}
manage_etc_hosts: true
package_upgrade: true
ssh_authorized_keys:
  - ${var.pub_key}
users:
  - default
chpasswd:
    expire: false
write_files:
  - path: /root/setup.sh
    permissions: 0744
    owner: root
    content: |
      #!/usr/bin/env bash
      set -e
      apt update && apt upgrade -y
      apt install linux-modules-$(uname -r) linux-modules-extra-$(uname -r)
      echo fs.inotify.max_user_watches=1048576 | tee -a /etc/sysctl.conf
      echo fs.inotify.max_user_instances=512000 | tee -a /etc/sysctl.conf
      echo vm.max_map_count=524288 | tee -a /etc/sysctl.conf
      echo user.max_user_namespaces=150000 | tee -a /etc/sysctl.conf
      sysctl -p
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=agent INSTALL_K3S_CHANNEL=${var.k3s_channel} sh -
  - path: /etc/rancher/k3s/config.yaml
    permissions: 0744
    owner: root
    content: |
      token-file: /opt/tokenfile
      server: "https://${var.k3s_url}:6443"
      node-name: ${each.key}
  - path: /opt/tokenfile
    permissions: 0700
    owner: root
    content: |
      ${var.k3s_token}
runcmd:
  - bash /root/setup.sh
  - reboot now
EOF

    file_name = "worker.${each.key}.cloud-config.yaml"
  }
}
