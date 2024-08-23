#!/bin/bash
    set -ex
    
   # Get OS type
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Cannot determine the operating system."
    fi

    # Run the command only if the OS is not Ubuntu
    if [ "$OS" != "ubuntu" ]; then
        echo "Running command on $OS"
        
        sudo yum install redhat-lsb-core -y
    else
        echo "Skipping command on Ubuntu"
    fi
    
    if command -v lsb_release &> /dev/null
    then
        OS_TYPE=$(lsb_release -a | grep "Description" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
    else
        echo "Operating System could not be determined."
    fi

    STORAGE_ACCOUNT_NAME="cftptlintsvc"    
    CONTAINER_NAME="xdr-collectors"

install_azcli() {
    # Install Azure CLI (if not already installed)
    
    if ! command -v az &> /dev/null
    then

        if [ "$OS" != "ubuntu" ]; then
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            rpm -q dnf || sudo yum install dnf -y
        fi

        if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
                        echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo

           sudo dnf clean all
           sudo dnf -v install azure-cli -y
        elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"8."* ]]; then
            sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm

            sudo dnf install azure-cli
        elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"9."* ]]; then
           sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm

           sudo dnf install azure-cli
        else
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        fi
    else
        echo "Azure CLI is already installed."
    fi
    
}

install_agent() {
    echo "Info: Installing XDR Agents"

    if [ "$OS" != "ubuntu" ]; then
        sudo yum install -y selinux-policy-devel
    else
        sudo apt-get update
        sudo apt-get install -y selinux-utils policycoreutils
    fi
    
    local SA_KEY="$1"
    local ENV="$2"
    local XDR_TAGS="$3"

    local DEFAULT_TAGS="hmcts,server"
    local ALL_TAGS="${DEFAULT_TAGS},${XDR_TAGS},${ENV}"

    local STRING_TO_APPEND="
--endpoint-tags ${ALL_TAGS}"

    mkdir -p XDR_DOWNLOAD

    if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux"* ]]; then

        # Download conf file
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_rpm/cortex.conf"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortex.conf"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        sudo echo "$STRING_TO_APPEND" >> $LOCAL_FILE_PATH
        sudo mkdir -p /etc/panw
        sudo cp $LOCAL_FILE_PATH /etc/panw/
        
        # Install agent
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_rpm_8.5.0.125392/cortex-8.5.0.125392.rpm"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortexagent.rpm"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        rpm -qa | grep -i cortex-agent || rpm -Uh $LOCAL_FILE_PATH
        rm -rf $LOCAL_FILE_PATH
        echo "Installation of Agents on RedHat VM completed"
    else

        # Download conf file
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_deb/cortex.conf"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortex.conf"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        sudo echo "$STRING_TO_APPEND" >> $LOCAL_FILE_PATH
        sudo mkdir -p /etc/panw
        sudo cp $LOCAL_FILE_PATH /etc/panw/
        
         # Install agent
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_deb_8.5.0.125392/cortex-8.5.0.125392.deb"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortexagent.deb"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        dpkg -l | grep -i cortex-agent || dpkg -i $LOCAL_FILE_PATH
        rm -rf $LOCAL_FILE_PATH

        echo "Installation of Agents on Ubuntu VM completed"
    fi
}

install_collector() {
    echo "Info: Installing XDR Collectors"
    
    if [ "$OS" != "ubuntu" ]; then
        sudo yum install -y selinux-policy-devel
    else
        sudo apt-get update
        sudo apt-get install -y selinux-utils policycoreutils
    fi

    local SA_KEY="$1"
    local ENV="$2"

    mkdir -p XDR_DOWNLOAD

    if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux"* ]]; then

        # Download collector file
        local BLOB_NAME="${ENV}/collector-1.4.1.1089.rpm/collector.conf"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/collector.conf"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        sudo mkdir -p /etc/panw
        sudo cp $LOCAL_FILE_PATH /etc/panw/
        
        # Install collector
        local BLOB_NAME="${ENV}/collector-1.4.1.1089.rpm/collector-1.4.1.1089.rpm"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/collector.rpm"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        rpm -qa | grep -i xdr-collector || rpm -Uh $LOCAL_FILE_PATH
        rm -rf $LOCAL_FILE_PATH
        echo "Installation of collectors on RedHat VM completed"
    else

        # Download collector file
        local BLOB_NAME="${ENV}/collector-1.4.1.1089.deb/collector.conf"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/collector.conf"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        sudo mkdir -p /etc/panw
        sudo cp $LOCAL_FILE_PATH /etc/panw/
        
         # Install collector
        local BLOB_NAME="${ENV}/collector-1.4.1.1089.deb/collector-1.4.1.1089.deb"
        local LOCAL_FILE_PATH="XDR_DOWNLOAD/collector.deb"
        download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        dpkg -l | grep -i xdr-collector || dpkg -i $LOCAL_FILE_PATH
        rm -rf $LOCAL_FILE_PATH

        echo "Installation of collectors on Ubuntu VM completed"
    fi
}

download_blob(){
    local STORAGE_ACCOUNT_NAME="$1"
    local SA_KEY="$2"
    local CONTAINER_NAME="$3"
    local BLOB_NAME="$4"
    local LOCAL_FILE_PATH="$5"
    az storage blob download --account-name $STORAGE_ACCOUNT_NAME --account-key $SA_KEY --container-name $CONTAINER_NAME --name $BLOB_NAME --file $LOCAL_FILE_PATH
}



if [ "${RUN_XDR_AGENT}" = "true" ]
then
  install_azcli
  install_agent "${STORAGE_ACCOUNT_KEY}" "${ENV}"
fi

if [ "${RUN_XDR_COLLECTOR}" = "true" ]
then
  install_azcli
  install_collector "${STORAGE_ACCOUNT_KEY}" "${ENV}"
fi
