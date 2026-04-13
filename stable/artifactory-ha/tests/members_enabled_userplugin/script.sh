hostname=$(kubectl get svc rt-nginx -n kuttl-test-huge-ant -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
response=$(curl -s -o /dev/null -w "%{http_code}" -u admin:password -XPOST "http://$hostname/artifactory/api/plugins/execute/helloWorld")
if [ "$response" -eq 200 ]; then
    echo "UserPlugin has been successfully loaded"
else
    echo "Request failed with status code: $response"
    exit 1
fi