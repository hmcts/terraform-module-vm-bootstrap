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
groupadd splunk
adduser --system -g splunk splunk
elif [[ "$OS_TYPE" == *"Ubuntu"* ]]; then
apt install acl
adduser --system --group splunk
else
adduser --system --group splunk
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

# Setup
SERVER=$1
KEY=$2
GROUPS=$3

# Get OS type
OS_TYPE=$(lsb_release -a | grep "Description" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')

# Download nessus agent
if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux Server release 6"* ]]; then
    # Set for RHEL6 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/16734/download?i_agree_to_tenable_license_agreement=true"
elif [[ "$OS_TYPE" == *"Red Hat Enterprise Linux Server release 7"* ]]; then
    # Set for RHEL7 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/16736/download?i_agree_to_tenable_license_agreement=true"
elif [[ "$OS_TYPE" == *"Red Hat Enterprise Linux Server release 8*"* ]]; then
    # Set for RHEL8 agent (RPM)
    INSTALL_FILE="nessusagent.rpm"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/16737/download?i_agree_to_tenable_license_agreement=true"
else
    # Set for Debian agent (deb) AMD64
    INSTALL_FILE="nessusagent.deb"
    DOWNLOAD_URL="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/16746/download?i_agree_to_tenable_license_agreement=true"
fi

# Install nessus agent
curl --retry 3 -# -L -k -o $INSTALL_FILE $DOWNLOAD_URL
if [[ "$OS_TYPE" == *"Red Hat Enterprise Linux"* ]]; then
    rpm -ivh nessusagent.rpm
    rm -rf nessusagent.rpm
else
    dpkg -i nessusagent.deb
    rm -rf nessusagent.deb
fi

# Start Service
/sbin/service nessusagent start
# Link agent
/opt/nessus_agent/sbin/nessuscli agent link --key=$KEY --groups=$GROUPS --host=$SERVER --port=8834
}

if [ "${UF_INSTALL}" = "true" ]
then
  install_splunk_uf "${UF_USERNAME}" "${UF_PASSWORD}" "${UF_PASS4SYMMKEY}" "${UF_GROUP}"
fi

if [ "${NESSUS_INSTALL}" = "true" ]
then
  install_nessus "${NESSUS_SERVER}" "${NESSUS_KEY}" "${UF_PASS4SYMMKEY}" "${NESSUS_GROUPS}"
fi
