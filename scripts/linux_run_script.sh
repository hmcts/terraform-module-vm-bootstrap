#!/bin/bash
set -ex

# Get OS type/version/name
check_os_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_TYPE=$NAME
    VERSION=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    OS_TYPE=$(lsb_release -sd | sed 's/"//g')
    VERSION=$(lsb_release -sr)
  elif [ -f /etc/redhat-release ]; then
    OS=$(awk '{print $1$2$3$5}' /etc/redhat-release)
    OS_TYPE=$(awk '{print $1, $2, $3, $4, $5}' /etc/redhat-release)
    VERSION=$(cat /etc/redhat-release | sed 's/[^0-9.]*//g')
  else
    echo "Cannot determine the operating system."
  fi

  echo "Operating System: $OS"
  echo "Version: $VERSION"
}

check_os_version

# Run the command only if the OS is not Ubuntu
if [ "$OS" != "ubuntu" ]; then
  echo "Running command on $OS"
  sudo yum install redhat-lsb-core -y
else
  echo "Skipping command on Ubuntu"
fi

STORAGE_ACCOUNT_NAME="cftptlintsvc"
CONTAINER_NAME="xdr-collectors"

install_azcopy() {
  # Install Azure CLI (if not already installed)

  if ! command -v azcopy &>/dev/null; then
    if [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"6."* ]]; then
      echo "Downloading AzCopy"
      sudo wget https://aka.ms/downloadazcopy-v10-linux
      sudo tar -xvf downloadazcopy-v10-linux

      echo "Adding AzCopy to path"
      sudo rm -f /usr/bin/azcopy
      sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
      sudo chmod 755 /usr/bin/azcopy

      echo "Completing cleanup"
      sudo rm -f downloadazcopy-v10-linux
      sudo rm -rf ./azcopy_linux_amd64_*/
    fi
  else
    echo "AzCopy is already installed."
  fi

}

install_azcli() {
  # Install Azure CLI (if not already installed)

  if ! command -v az &>/dev/null; then

    if [ "$OS" != "ubuntu" ]; then
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      rpm -q dnf || sudo yum install dnf -y
    fi
    if [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"7."* ]]; then
      echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo

      sudo dnf clean all
      sudo dnf -v install azure-cli -y

    elif [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"8."* ]]; then
      sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
      sudo dnf install azure-cli

    elif [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"9."* ]]; then
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

  local STRING_TO_APPEND="
--endpoint-tags ${XDR_TAGS}"

  mkdir -p XDR_DOWNLOAD

  if [[ $OS_TYPE == *"Red Hat Enterprise Linux"* ]]; then
    # Download conf file
    local BLOB_NAME="${ENV}/${ENV}_agent-HMCTS_Linux_rpm_8.5.0.125392/cortex.conf"
    local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortex.conf"
    download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
    sudo echo "$STRING_TO_APPEND" >>$LOCAL_FILE_PATH
    sudo mkdir -p /etc/panw
    sudo cp $LOCAL_FILE_PATH /etc/panw/

    # Install agent
    local BLOB_NAME="${ENV}/${ENV}_agent-HMCTS_Linux_rpm_8.5.0.125392/cortex-8.5.0.125392.rpm"
    local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortexagent.rpm"
    download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
    rpm -qa | grep -i cortex-agent || sudo rpm -Uh $LOCAL_FILE_PATH
    rm -rf $LOCAL_FILE_PATH
    echo "Installation of Agents on RedHat VM completed"
  else

    # Download conf file
    local BLOB_NAME="${ENV}/${ENV}_agent-HMCTS_Linux_deb_8.5.0.125392/cortex.conf"
    local LOCAL_FILE_PATH="XDR_DOWNLOAD/cortex.conf"
    download_blob "$STORAGE_ACCOUNT_NAME" "$SA_KEY" "$CONTAINER_NAME" "$BLOB_NAME" "$LOCAL_FILE_PATH"
    sudo echo "$STRING_TO_APPEND" >>$LOCAL_FILE_PATH
    sudo mkdir -p /etc/panw
    sudo cp $LOCAL_FILE_PATH /etc/panw/

    # Install agent
    local BLOB_NAME="${ENV}/${ENV}_agent-HMCTS_Linux_deb_8.5.0.125392/cortex-8.5.0.125392.deb"
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

  if [[ $OS_TYPE == *"Red Hat Enterprise Linux"* ]]; then

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
    rpm -qa | grep -i xdr-collector || sudo rpm -Uh $LOCAL_FILE_PATH
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

download_blob() {
  local STORAGE_ACCOUNT_NAME="$1"
  local SA_KEY="$2"
  local CONTAINER_NAME="$3"
  local BLOB_NAME="$4"
  local LOCAL_FILE_PATH="$5"

  if [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"6."* ]]; then
    # This command uses SA_KEY as a variable but it should be a SAS Token for RHEL 6 VMs
    azcopy copy "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME/$BLOB_NAME?$SA_KEY" "$LOCAL_FILE_PATH"
  else
    az storage blob download --account-name $STORAGE_ACCOUNT_NAME --account-key $SA_KEY --container-name $CONTAINER_NAME --name $BLOB_NAME --file $LOCAL_FILE_PATH
  fi
}

install_docker() {

  echo "Info: Installing Docker and Docker Compose"

  if [ "$OS" == "ubuntu" ]; then

    if ! command -v docker &>/dev/null; then
      apt update
      apt install -y apt-transport-https ca-certificates curl software-properties-common

      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

      apt update
      apt install -y docker-ce
    fi

    DOCKER_PLUGINS_DIR="/usr/local/lib/docker/cli-plugins"

    if [ ! -d "$DOCKER_PLUGINS_DIR" ]; then
      mkdir -p "$DOCKER_PLUGINS_DIR"
      if [ ! -f "$DOCKER_PLUGINS_DIR/docker-compose" ]; then
        curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
      fi
    fi
  fi
}

if [ "${RUN_XDR_AGENT}" = "true" ]; then
  if [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"6."* ]]; then
    install_azcopy
  else
    install_azcli
  fi
  install_agent "${STORAGE_ACCOUNT_KEY}" "${ENV}" "${XDR_TAGS}"
fi

if [ "${RUN_XDR_COLLECTOR}" = "true" ]; then
  if [[ $OS_TYPE == *"Red Hat Enterprise"* && $VERSION == *"6."* ]]; then
    install_azcopy
  else
    install_azcli
  fi
  install_collector "${STORAGE_ACCOUNT_KEY}" "${ENV}"
fi

if [ "${INSTALL_DOCKER}" = "true" ]; then
  install_docker
fi
