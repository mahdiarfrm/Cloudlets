# Cloudlets

A project that automates the deployment of KVM virtual machines using Terraform and a customizable Bash script. This setup allows for quick and consistent provisioning of VMs with user-defined configurations, including CPU, RAM, disk size, and network settings.

## Features

* Automated Deployment: Use a Bash script to automate the entire VM provisioning process.
* User Input: The script prompts for all necessary configurations, such as VM name, resources, and network settings.
* Terraform Integration: Leverages Terraform to manage and provision infrastructure efficiently.
* Customizable Configurations: Easily adjust CPU, RAM, disk size, and network interfaces with static IPs.
* Cloud-Init Support: Utilize cloud-init templates for initial VM setup, including user creation and SSH key deployment.
* Supports Multiple Networks: Configure multiple network interfaces connected to different bridges.

## Prerequisites

* Operating System: Linux (Debian-based distributions recommended, e.g., Ubuntu)
* Installed Software:
   * KVM and Libvirt: qemu-kvm, libvirt-daemon-system, libvirt-clients, bridge-utils, virt-manager
   * Terraform: Installed via script if not present
   * Bash: For running the setup script
* User Permissions: User running the script should have sudo privileges

## Installation & Usage

1. Clone the Repository

```
git clone https://github.com/mahdiarfrm/Cloudlets.git
cd Cloudlets/
```

2. Make the Setup Script Executable and Run it

```
chmod +x terraform.sh
./terraform.sh
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes.

> **Disclaimer:** This project is provided as-is without any guarantees. Use it at your own risk, and ensure you understand the configurations and scripts before running them in your environment.
