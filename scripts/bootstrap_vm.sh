#!/bin/bash
#set -vxn

install_splunk_uf() {
DOWNLOAD_URL="https://download.splunk.com/products/universalforwarder/releases/8.2.2.1/linux/splunkforwarder-8.2.2.1-ae6821b7c64b-Linux-x86_64.tgz"
INSTALL_FILE="splunkforwarder-8.2.2.1-ae6821b7c64b-Linux-x86_64.tgz"
INSTALL_LOCATION="/opt"
DEPLOYMENT_SERVER_URI="splunk-lm-prod-vm00.platform.hmcts.net:8089"
FORWARD_SERVER_URI="splunk-cm-prod-vm00.platform.hmcts.net:8089"
UF_USERNAME=$1
UF_PASSWORD=$2
UF_PASS4SYMMKEY=$3
UF_GROUP=$4

export SPLUNK_HOME="$INSTALL_LOCATION/splunkforwarder"

# Get OS type
OS_TYPE=$(hostnamectl | grep "Operating System" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')

# Create boot-start systemd user
if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux"* ]]; then
getent group splunk || groupadd splunk
id splunk || adduser --system -g splunk splunk
elif [[ "$OS_TYPE" == *"Ubuntu"* ]]; then
apt install acl
id splunk || adduser --system --group splunk
else
id splunk || adduser --system --group splunk
fi

# Install splunk forwarder
curl --retry 3 -# -L -o $INSTALL_FILE $DOWNLOAD_URL
tar xvzf $INSTALL_FILE -C $INSTALL_LOCATION
rm -rf $INSTALL_FILE
chown -R splunk:splunk $SPLUNK_HOME
setfacl -R -m u:splunk:r /var/log

if [  "$(systemctl is-active SplunkForwarder.service)" = "active"  ]; then
  $SPLUNK_HOME/bin/splunk stop
  sleep 10
fi

# Create splunk admin user
{
cat <<EOF
[user_info]
USERNAME = $UF_USERNAME
HASHED_PASSWORD = $($SPLUNK_HOME/bin/splunk hash-passwd $UF_PASSWORD)
EOF
} > $SPLUNK_HOME/etc/system/local/user-seed.conf

$SPLUNK_HOME/bin/splunk stop

# Start splunk forwarder
$SPLUNK_HOME/bin/splunk start --accept-license --no-prompt --answer-yes

# Set server name
$SPLUNK_HOME/bin/splunk set servername $hostname -auth $UF_USERNAME:$UF_PASSWORD
$SPLUNK_HOME/bin/splunk restart

# Configure deploymentclient.conf
{
cat <<EOF
[deployment-client]

[target-broker:deploymentServer]
# Settings for HMCTS DeploymentServer
targetUri = $DEPLOYMENT_SERVER_URI
EOF
} > $SPLUNK_HOME/etc/system/local/deploymentclient.conf


# Configure outputs.conf
{
cat <<EOF
[indexer_discovery:hmcts_cluster_manager]
pass4SymmKey = $UF_PASS4SYMMKEY
master_uri = $FORWARD_SERVER_URI

[tcpout:hmcts_forwarders]
autoLBFrequency = 30
forceTimebasedAutoLB = true
indexerDiscovery = hmcts_cluster_manager
useACK=true

[tcpout]
defaultGroup = hmcts_forwarders
EOF
} > $SPLUNK_HOME/etc/system/local/outputs.conf

# Create boot-start systemd service
$SPLUNK_HOME/bin/splunk stop
$SPLUNK_HOME/bin/splunk disable boot-start
sleep 10
$SPLUNK_HOME/bin/splunk enable boot-start -systemd-managed 1 -user splunk -group splunk
chown -R splunk:splunk $SPLUNK_HOME

$SPLUNK_HOME/bin/splunk start
}

install_nessus() {
echo "Info: Installing Tenable Nessus"

# Setup
SERVER=$1
KEY=$2
GROUPS=$3

# Get OS type
if command -v hostnamectl &> /dev/null
then
    OS_TYPE=$(hostnamectl | grep "Operating System" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
elif command -v lsb_release &> /dev/null
then
    OS_TYPE=$(lsb_release -a | grep "Description" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
else
    echo "Operating System could not be determined."
fi

# Download URLs for nessus agents are listed at: 
#     https://www.tenable.com/downloads/api/v2/pages/nessus-agents
# As of 14-Jun-2024, the downloads in the returned JSON all have the 'OS' field
# set to 'null'. I've hardcoded them as a stop-gap. if later versions of the
# agents list their OS, we may be able to automate the OS selection. JQ will
# need to be available for this, we can just curl a release from github and
# invoke it directly.
# TODO: SHA265 hashes for the agent installers are provided, we should check
#       them against the downloaded files before we install

# Download nessus agent
if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"6."* ]]; then
    # Set for RHEL6 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el6.x86_64.rpm"
elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
    # Set for RHEL7 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el7.x86_64.rpm"
elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"8."* ]]; then
    # Set for RHEL8 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el8.x86_64.rpm"
elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"9."* ]]; then
    # Set for RHEL9 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-el9.x86_64.rpm"
else
    # Set for Ubuntu agent (deb) AMD64
    FILE_DESCRIPTION="Ubuntu 14.04, 16.04, 18.04, 20.04, 22.04 (amd64)"
    # The only AMD64 build of the agent Tenable publish for ubuntu is for
    # ubuntu 14.04. Should work on later versions?
    INSTALL_FILE="nessusagent.deb"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v2/pages/nessus-agents/files/NessusAgent-latest-ubuntu1404_amd64.deb"
fi

# Install nessus agent
curl --retry 3 -# -L -k -o $INSTALL_FILE $DOWNLOAD_URL
if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux"* ]]; then
    /opt/nessus_agent/sbin/nessuscli agent status || rpm -Uh nessusagent.rpm
    rm -rf nessusagent.rpm
else
    /opt/nessus_agent/sbin/nessuscli agent status || dpkg -i nessusagent.deb
    rm -rf nessusagent.deb
fi

# Start Service
/sbin/service nessusagent start

# Link agent
NESSUS_STATUS=$(/opt/nessus_agent/sbin/nessuscli agent status -a | grep "Link status" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
if [[ "$NESSUS_STATUS" == "Connected to"* ]]; then
    echo $NESSUS_STATUS
else
    echo "Connecting..."
    /opt/nessus_agent/sbin/nessuscli agent link --key=$KEY --groups=$GROUPS --host=$SERVER --port=8834
fi
}

# Exit on error
set +e

if [ "${UF_INSTALL}" = "true" ]
then
  install_splunk_uf "${UF_USERNAME}" "${UF_PASSWORD}" "${UF_PASS4SYMMKEY}" "${UF_GROUP}"
fi

if [ "${NESSUS_INSTALL}" = "true" ]
then
  install_nessus "${NESSUS_SERVER}" "${NESSUS_KEY}" "${NESSUS_GROUPS}"
fi

# Redhat ELS

keyvaultName="infra-vault-nonprod"
secretName="rhel-cert"

# Retrieve the certificate content from Azure Key Vault
certificateContent=$(az keyvault secret show --vault-name $keyvaultName --name $secretName --query value -o tsv)

# Check if the retrieval was successful
if [ -z "$certificateContent" ]; then
  echo "Failed to retrieve the certificate from Azure Key Vault."
  exit 1
fi

# Create directory /etc/pki/product/.
mkdir -p /etc/pki/product/

# Write the certificate.
echo "$certificateContent" > /etc/pki/product/204.pem

# Change the permission and ownership of this file.
restorecon -Rv /etc/pki/product
chown root.root /etc/pki/product/204.pem
chmod 644 /etc/pki/product/204.pem
rct cat-cert /etc/pki/product/204.pem

# Check if the OS is RHEL 7
if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
    echo "This is Red Hat Enterprise Linux 7."
    
    # Register the system and attach a subscription pool
    subscription-manager register --org=7324337 --activationkey=Rhel-els


    # Refresh subscription-manager and verify identity
    subscription-manager refresh
    subscription-manager identity

    # Install insights-client and register it
    yum install -y insights-client
    insights-client --register

    # Enable repositories
    subscription-manager config --rhsm.manage_repos=1
    subscription-manager repos --enable rhel-7-server-els-rpms

      echo "Configuration completed successfully."
else
    echo "This script is intended for Red Hat Enterprise Linux 7 only."
fi