#!/bin/bash
    set -ex
    echo "entry 1"
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
        echo "entry 2"
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

echo "entry 3"

install-azcli() {
    # Install Azure CLI (if not already installed)
    echo "entry 4"
    if ! command -v az &> /dev/null
    then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        rpm -q dnf || sudo yum install dnf -y

        if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
                        echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo

            sudo dnf install azure-cli
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

install-agent() {
    echo "Info: Installing XDR Agents"
    sudo yum install -y selinux-policy-devel

    local SA_KEY="$1"
    local ENV="$2"

    STORAGE_ACCOUNT_NAME="cftptlintsvc"
    
    CONTAINER_NAME="xdr-collectors"
    STRING_TO_APPEND="
--endpoint-tags hmcts,server"

    mkdir -p /XDR_DOWNLOAD

 

    if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux"* ]]; then

        # Download conf file
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_rpm/cortex.conf"
        local LOCAL_FILE_PATH="./XDR_DOWNLOAD/cortex.conf"
        download-blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        sudo echo "$STRING_TO_APPEND" >> $LOCAL_FILE_PATH
        sudo mkdir -p /etc/panw
        sudo cp $LOCAL_FILE_PATH /etc/panw/
        
        # Install agent
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_rpm/cortex-8.4.0.123787.rpm"
        local LOCAL_FILE_PATH="./XDR_DOWNLOAD/cortexagent.rpm"
        download-blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        rpm -qa | grep -i cortex-agent || rpm -Uh $LOCAL_FILE_PATH
        rm -rf $LOCAL_FILE_PATH

        echo "Installation of Agents on RedHat VM completed"
    else

        # Download conf file
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_deb/cortex.conf"
        local LOCAL_FILE_PATH="./XDR_DOWNLOAD/cortex.conf"
        download-blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        sudo echo "$STRING_TO_APPEND" >> $LOCAL_FILE_PATH
        sudo mkdir -p /etc/panw
        sudo cp $LOCAL_FILE_PATH /etc/panw/
        
         # Install agent
        local BLOB_NAME="${ENV}/agent-HMCTS_Linux_deb/cortex-8.4.0.123787.deb"
        local LOCAL_FILE_PATH="./XDR_DOWNLOAD/cortexagent.deb"
        download-blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
        dpkg -l | grep -i cortex-agent || dpkg -i $LOCAL_FILE_PATH
        rm -rf $LOCAL_FILE_PATH

        echo "Installation of Agents on Ubuntu VM completed"
    fi
}

download-blob(){
    local STORAGE_ACCOUNT_NAME="$1"
    local SA_KEY="$2"
    local CONTAINER_NAME="$3"
    local BLOB_NAME="$4"
    local LOCAL_FILE_PATH="$5"
    az storage blob download --account-name $STORAGE_ACCOUNT_NAME --account-key $SA_KEY --container-name $CONTAINER_NAME --name $BLOB_NAME --file $LOCAL_FILE_PATH
}



if [ "${RUN_XDR_AGENT}" = "true" ]
then
  echo "entry 5"
  install-azcli
  install-agent "${STORAGE_ACCOUNT_KEY}" "${ENV}"
fi

if [ "${RUN_XDR_COLLECTOR}" = "true" ]
then
#   install-collector
    echo "Work in progress related to XDR collectors"
fi
