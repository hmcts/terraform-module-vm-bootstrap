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
if command -v hostnamectl &> /dev/null
then
    OS_TYPE=$(hostnamectl | grep "Operating System" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
elif command -v lsb_release &> /dev/null
then
    OS_TYPE=$(lsb_release -a | grep "Description" | cut -f2 -d: | sed -e 's/^[[:space:]]*//')
else
    echo "Operating System could not be determined."
fi

echo "Operating system type: $OS_TYPE"

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

if [[ $(command -v systemctl) ]]; then
  if [  "$(systemctl is-active SplunkForwarder.service)" = "active"  ]; then
    $SPLUNK_HOME/bin/splunk stop
    sleep 10
  fi
else
  if [[ "$($SPLUNK_HOME/bin/splunk status)" = "splunkd is running"*  ]]; then
    $SPLUNK_HOME/bin/splunk stop
    sleep 10
  fi
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

if [[ $(command -v systemctl) ]]; then
  $SPLUNK_HOME/bin/splunk enable boot-start -systemd-managed 1 -user splunk -group splunk
else
  $SPLUNK_HOME/bin/splunk enable boot-start -user splunk -group splunk
fi

chown -R splunk:splunk $SPLUNK_HOME

$SPLUNK_HOME/bin/splunk start
}

get_download_id () {
  wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  chmod +x ./jq
  cp jq /usr/bin
  json_data=$(curl -L --request GET --url 'https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/' --header 'Accept: aplication/json')
  download_id=$(jq --arg desc "$1" '.. | select(.description? == $desc) | .id' <<< "$json_data")
  highest=$(echo "$download_id" | tr ' ' '\n' | sort -n | tail -n 1)
  echo "$highest"
}

check_download_url () {
 # use curl to get the HTTP status code
  url="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/$1/download?i_agree_to_tenable_license_agreement=true"
  urlstatus=$(curl -o /dev/null --silent --head --write-out '%%{http_code}' "$url")
  # if the status code is 404, print a message and exit with 1
  if [ "$urlstatus" == "404" ]; then
    echo "The URL $url gives 404 error"
    exit 1
  else
    echo "$url"
  fi
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

  # Download nessus agent
  if [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"6."* ]]; then
      # Set for RHEL6 agent (RPM)
      FILE_DESCRIPTION="Red Hat ES 6 / Oracle Linux 6 (including Unbreakable Enterprise Kernel) (x86_64)"
      INSTALL_FILE="nessusagent.rpm"
      id="$(get_download_id "$FILE_DESCRIPTION")"
      DOWNLOAD_URL=$(check_download_url "$id")
  elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"7."* ]]; then
      # Set for RHEL7 agent (RPM)
      FILE_DESCRIPTION="Red Hat ES 7 / CentOS 7 / Oracle Linux 7 (including Unbreakable Enterprise Kernel) (x86_64)"
      INSTALL_FILE="nessusagent.rpm"
      id="$(get_download_id "$FILE_DESCRIPTION")"
      DOWNLOAD_URL=$(check_download_url "$id")
  elif [[ "$OS_TYPE" == *"Red Hat Enterprise"* && "$OS_TYPE" == *"8."* ]]; then
      # Set for RHEL8 agent (RPM)
      FILE_DESCRIPTION="Red Hat ES 8, 9 / Alma Linux 8, 9 / Rocky Linux 8, 9 / Oracle Linux 8, 9 / (including Unbreakable Enterprise Kernel) (x86_64)"
      INSTALL_FILE="nessusagent.rpm"
      id="$(get_download_id "$FILE_DESCRIPTION")"
      DOWNLOAD_URL=$(check_download_url "$id")
  else
      # Set for Ubuntu agent (deb) AMD64
      FILE_DESCRIPTION="Ubuntu 14.04, 16.04, 18.04, 20.04, 22.04 (amd64)"
      INSTALL_FILE="nessusagent.deb"
      id="$(get_download_id "$FILE_DESCRIPTION")"
      DOWNLOAD_URL=$(check_download_url "$id")
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
set -e

if [ "${UF_INSTALL}" = "true" ]
then
  install_splunk_uf "${UF_USERNAME}" "${UF_PASSWORD}" "${UF_PASS4SYMMKEY}" "${UF_GROUP}"
fi

if [ "${NESSUS_INSTALL}" = "true" ]
then
  # Install nessus if not present
  /opt/nessus_agent/sbin/nessuscli agent status || install_nessus "${NESSUS_SERVER}" "${NESSUS_KEY}" "${NESSUS_GROUPS}"
fi
