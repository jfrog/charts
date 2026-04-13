#!/bin/sh

isCertAdded=$(/opt/jfrog/artifactory/app/third-party/java/bin/keytool -list -keystore /opt/jfrog/artifactory/var/data/java/keys/cacerts -storepass changeit -alias sample.crt)

# Should contain "trustedCertEntry" if the certificate was added successfully
if echo "$isCertAdded" | grep -q "trustedCertEntry"; then
    echo "Certificate was successfully added"
else
    echo "Custom Cert store isn't working properly, please check"
    echo "Keytool output: $isCertAdded"
    exit 1
fi
echo "Certificate log: $isCertAdded"

# check for Java flags for new cert path
processString=$(ps -ef | grep -i artifactory | grep -vE "grep|/bin/bash|bin/sh")

if echo "$processString" | grep -q "\-Djavax\.net\.ssl\.trustStore=/opt/jfrog/artifactory/var/data/java/keys/cacerts"; then
    echo "Java flags are set correctly for the new cert path"
else
    echo "Java flags are not set correctly for the new cert path"
    echo "Process string: $processString"
    exit 1
fi

artPid=$(ps -ef | grep -i artifactory | grep -vE "grep|/bin/bash|bin/sh" | awk '{print $2}')
echo "Artifactory PID: $artPid"

if [ -z "$artPid" ]; then
    echo "Artifactory process not found"
    exit 1
fi

# Call jinfo to check if it works with the Artifactory process
jInfoTest=$(/opt/jfrog/artifactory/app/third-party/java/bin/jinfo -flags "$artPid")

# check exit code
if [ $? -ne 0 ]; then
    echo "Failed to call jinfo on Artifactory process with PID $artPid"
    echo "Logs: $jInfoTest"
    exit 1
else
    echo "JInfo worked successfully"
fi