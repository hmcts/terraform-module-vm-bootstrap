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
then
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

if [ "${UF_INSTALL}" = "true" ]
then
  install_splunk_uf "${UF_USERNAME}" "${UF_PASSWORD}" "${UF_PASS4SYMMKEY}" "${UF_GROUP}"
fi