#!/bin/bash
openapi2apigee generateApi petStore -s ${OpenAPI_Spec_Location} -d /home/jenkins/agent/workspace/test/
cd /home/jenkins/agent/workspace/test/petStore 
HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --header "Authorization: Basic YXNoYXJtYTM4M0BzYXBpZW50LmNvbTpEZWNAMjAxOQ==" -F "file=@apiproxy.zip" "https://api.enterprise.apigee.com/v1/organizations/asharma383-eval/apis?action=import&name=${Proxy_Name}")

# extract the body
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

# extract the status
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo "$HTTP_STATUS"

# print the body
echo "$HTTP_BODY" > temp.json
REVISION=$( grep -o '"revision" : *"[^"]*"' temp.json | grep -o '"[^"]*"$' | sed 's/"//g')
# example using the status
if [ $HTTP_STATUS -eq 201  ]
        then
        echo "Proxy is uploaded successfully [HTTP status: $HTTP_STATUS]"
        echo "$REVISION"
        else
         exit 1
fi
DEPLOY_HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Authorization: Basic YXNoYXJtYTM4M0BzYXBpZW50LmNvbTpEZWNAMjAxOQ==" "https://api.enterprise.apigee.com/v1/organizations/asharma383-eval/environments/prod/apis/${Proxy_Name}/revisions/$REVISION/deployments?override=true")

# extract the status
DEPLOY_HTTP_STATUS=$(echo $DEPLOY_HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ $DEPLOY_HTTP_STATUS -eq 200  ]
        then
        echo "Proxy is deployed successfully [HTTP status: $HTTP_STATUS]"
        else
         exit 1
fi