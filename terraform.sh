#!/bin/bash

set -e

cat << 'EOF'

Welcome to
   _____ _                 _ _      _       
  / ____| |               | | |    | |      
 | |    | | ___  _   _  __| | | ___| |_ ___ 
 | |    | |/ _ \| | | |/ _` | |/ _ \ __/ __|
 | |____| | (_) | |_| | (_| | |  __/ |_\__ \
  \_____|_|\___/ \__,_|\__,_|_|\___|\__|___/
                                            
                                            
EOF

if ! grep -qi "ubuntu" /etc/os-release; then
    echo "[-] Only Ubuntu is supported at the moment."
    exit 1
fi

if ! command -v kvm-ok &> /dev/null; then
    echo "This script works with KVM. Please ensure KVM is installed."
    exit 1
fi

if ! kvm-ok | grep -qi "can be used"; then
    echo "KVM is either not enabled or not supported on this system."
    exit 1
fi

echo "All checks passed. Proceeding with the script..."

#set_dns_servers() {
#    echo "Setting DNS servers..."
#    sudo cp /etc/resolv.conf /etc/resolv.conf.backup.$(date +%Y%m%d%H%M%S)
#    echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" | sudo tee /etc/resolv.conf
#}

install_terraform() {
    if ! command -v terraform &> /dev/null
    then
        echo "Terraform is not installed. Installing Terraform..."

        sudo apt-get update
        sudo apt-get install -y gnupg software-properties-common curl genisoimage 

        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

        sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

        sudo apt-get update && sudo apt-get install -y terraform
    else
        echo "Terraform is already installed."
    fi
}

update_provider_uri() {
    if [ ! -f provider.tf ]; then
        echo "Error: provider.tf not found in the current directory."
        exit 1
    fi

    read -p "Enter the KVM host URI (default is qemu:///system): " KVM_URI
    KVM_URI=${KVM_URI:-"qemu:///system"}

    echo "Updating provider.tf with the KVM URI..."
    sed -i "s|^\s*uri\s*=.*$|  uri = \"${KVM_URI}\"|" provider.tf
}

get_variable_values() {
    echo "Please provide the following information:"

    read -p "VM Name: " VM_NAME

    read -p "Number of CPUs [default 2]: " CPU
    CPU=${CPU:-2}

    read -p "Amount of RAM in MB [default 2048]: " RAM
    RAM=${RAM:-2048}

    read -p "Disk size in GB [default 20]: " DISK_SIZE
    DISK_SIZE=${DISK_SIZE:-20}

    read -p "Username for the VM [default 'ubuntu']: " USERNAME
    USERNAME=${USERNAME:-"ubuntu"}

    read -s -p "Password for the VM user: " PASSWORD
    echo
    if [ -z "$PASSWORD" ]; then
        echo "Password cannot be empty."
        exit 1
    fi

    read -p "Name of the first bridge <Public> (e.g., br0) [default 'br0']: " BRIDGE1_NAME
    BRIDGE1_NAME=${BRIDGE1_NAME:-"br0"}

    read -p "Name of the second bridge <Private> (e.g., br1) [default 'br1']: " BRIDGE2_NAME
    BRIDGE2_NAME=${BRIDGE2_NAME:-"br1"}

    echo "Interface 1 (connected to ${BRIDGE1_NAME}):"
    read -p "Enter IP address for interface 1 (e.g., 192.168.1.X Public): " IF1_IP
    read -p "Enter subnet mask for interface 1 (e.g., 255.255.255.0): " IF1_NETMASK
    read -p "Enter gateway for interface 1 (e.g., 192.168.1.1): " IF1_GATEWAY
    read -p "Enter DNS servers for interface 1 (comma-separated, e.g., 8.8.8.8,8.8.4.4): " IF1_DNS

    echo "Interface 2 (connected to ${BRIDGE2_NAME}):"
    read -p "Enter IP address for interface 2 (e.g., 10.0.0.X Private): " IF2_IP
    read -p "Enter subnet mask for interface 2 (e.g., 255.255.255.0): " IF2_NETMASK
    #read -p "Enter gateway for interface 2 (e.g., 10.0.0.1): " IF2_GATEWAY
    #read -p "Enter DNS servers for interface 2 (comma-separated, e.g., 1.1.1.1,8.8.8.8): " IF2_DNS

}

mask2cidr() {
    local netmask=$1
    local cidr=0
    IFS=.
    for octet in $netmask; do
        case $octet in
            255) ((cidr+=8));;
            254) ((cidr+=7));;
            252) ((cidr+=6));;
            248) ((cidr+=5));;
            240) ((cidr+=4));;
            224) ((cidr+=3));;
            192) ((cidr+=2));;
            128) ((cidr+=1));;
            0);;
            *) echo "Invalid subnet mask: $netmask"; exit 1;;
        esac
    done
    unset IFS
    echo $cidr
}

# Create terraform.tfvars

create_tfvars() {
    echo "Creating terraform.tfvars with the provided variables..."

    CIDR1=$(mask2cidr ${IF1_NETMASK})
    CIDR2=$(mask2cidr ${IF2_NETMASK})

    DNS1=$(echo ${IF1_DNS} | sed 's/,/","/g;s/^/"/;s/$/"/')
    #DNS2=$(echo ${IF2_DNS} | sed 's/,/","/g;s/^/"/;s/$/"/')

    cat > terraform.tfvars <<EOL
vm_name = "${VM_NAME}"
memory = ${RAM}
vcpu = ${CPU}
disk_size = ${DISK_SIZE}
username = "${USERNAME}"
password = "${PASSWORD}"

bridge1_name = "${BRIDGE1_NAME}"
bridge2_name = "${BRIDGE2_NAME}"

vm_interface1_config = {
  dhcp4      = false
  addresses  = ["${IF1_IP}/${CIDR1}"]
  gateway4   = "${IF1_GATEWAY}"
  nameservers = {
    addresses = [${DNS1}]
  }
}

vm_interface2_config = {
  dhcp4      = false
  addresses  = ["${IF2_IP}/${CIDR2}"]
  nameservers = {
    addresses = [${DNS2}]
  }
}
EOL
}

# gateway4   = "${IF2_GATEWAY}"

run_terraform() {
    echo "[+] Initializing Terraform..."
    terraform init

    echo "[+] Planning Terraform deployment..."
    terraform plan

    echo "[+] Applying Terraform deployment..."
    terraform apply -auto-approve
}


#set_dns_servers
install_terraform
update_provider_uri
get_variable_values
create_tfvars
run_terraform

echo "[*] Script completed successfully."
