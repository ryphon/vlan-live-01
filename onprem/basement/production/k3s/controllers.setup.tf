resource "proxmox_virtual_environment_file" "controllers" {
  for_each = local.controllers
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
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=server INSTALL_K3S_CHANNEL=${var.k3s_channel} sh -
  - path: /etc/rancher/k3s/config.yaml
    permissions: 0744
    owner: root
    content: |
      token-file: /opt/tokenfile
      server: "https://${var.k3s_url}:6443"
      node-name: ${each.key}
      node-taint:
        - "CriticalAddonsOnly=true:NoExecute"
      tls-san:
        - "${var.vip}"
        - "${var.k3s_url}"
      disable:
        - traefik
        - servicelb
  - path: /opt/tokenfile
    permissions: 0744
    owner: root
    content: |
      ${trimspace(var.k3s_token)}
runcmd:
  - bash /root/setup.sh
  - reboot now
EOF

    file_name = "controller.${each.key}.cloud-config.yaml"
  }
}
