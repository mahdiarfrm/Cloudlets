#cloud-config
hostname: ${hostname}
users:
  - name: ${username}
    plain_text_passwd: ${password}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
ssh_pwauth: true
disable_root: false

network:
  version: 2
  ethernets:
    ${interface1_name}:
      ${interface1_config}
    ${interface2_name}:
      ${interface2_config}