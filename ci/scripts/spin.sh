#!/bin/bash
set -e -u -x
export GOPATH=$PWD/ops-repo
cd $GOPATH

echo "[awscli] Create s3 bucket"
aws s3api create-bucket --bucket $TEAMID-store --region eu-west-1
export KOPS_STATE_STORE=s3://$TEAMID-store 

echo "[kops] Creating AWS cluster"
kops create cluster --cloud aws --channel alpha --kubernetes-version 1.5.2 --dns-zone  $TEAMID.example.com  --master-size t2.medium  --master-zones eu-west-1a,eu-west-1b,eu-west-1c  --network-cidr 172.20.0.0/16 --node-count=3  --node-size t2.large  --zones eu-west-1a,eu-west-1b,eu-west-1c  --state s3://$TEAMID-store --name $TEAMID.example.com

echo "[kops] Pushing cluster"
kops update cluster $TEAMID.example.com --yes

echo "Waiting for DNS to update"
sleep 320

echo "[kubectl] Creating ebs storage"
kubectl create -f storage1.yaml
kubectl create -f storage2.yaml 
sleep 20

echo "[kubectl] Creating Kubernetes dashboard"
kubectl create -f kubernetes-dashboard.yaml

echo "[kubectl] Creating fluentd, elasticsearch and kibana pods"
kubectl create -f elastic.yaml 
sleep 20

echo "[kubectl] Creating ingress pod"
kubectl create -f ingress_rc.yaml
sleep 10
kubectl create -f ingress.yaml

kubectl create -f mongo/mongo.yaml

echo "Deploying applications to new Kubernetes infastructure"

echo "[kubectl] Deploying microservices"
kubectl create -f microservices.yaml

echo "Outputting ingress IPs"
kubectl get ing --all-namespaces

echo "Starting Grafana Services"
kubectl create -f influxdb/heapster-deployment.yaml
sleep 1
kubectl create -f influxdb/heapster-service.yaml
sleep 1
kubectl create -f influxdb/influxdb-deployment.yaml
sleep 1
kubectl create -f influxdb/influxdb-service.yaml
sleep 1
kubectl create -f influxdb/grafana-deployment.yaml
sleep 1
kubectl create -f influxdb/grafana-service.yaml

echo "Updating Security Group for Ingress"

GROUPID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="nodes.example.com" --query 'SecurityGroups[*].{Name:GroupName,ID:GroupId}' --region eu-west-1 | jq '.[0].ID' | sed -e 's/^"//' -e 's/"$//')
aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region eu-west-1

echo "DNS Update"
sleep 60
services=$(kubectl get services --namespace kube-system -o template --template='{{range.items}}{{.metadata.name}}{{","}}{{end}}')
ingress_ips=$(kubectl get ing --namespace kube-system -o template --template='{{range.items}}{{range.status.loadBalancer.ingress}}{{.ip}}{{","}}{{end}}{{end}}')

rm -rf /tmp/dns_update
mkdir /tmp/dns_update

trim_ips=${ingress_ips::-1}
IFS=',' read -ra addr <<< "$trim_ips"

trim_services=${services::-1}
IFS=',' read -ra svcs <<< "$trim_services"

b=0
for y in "${svcs[@]}"; do
	echo svcs["$b"]="$y".$TEAMID.example.com
	svcs["$b"]="$y".$TEAMID.example.com
	b=$((b+1))
done

for x in "${svcs[@]}"; do
	echo $x
	jq '.Changes[].ResourceRecordSet |= .+ {"Name": "'$x'"}' ci/scripts/dns_update.json >> /tmp/dns_update/"$x"_0.json
	a=0
	for i in "${addr[@]}"; do
		jq '.Changes[].ResourceRecordSet.ResourceRecords['$a'] |= .+{"Value": "'$i'"}' /tmp/dns_update/"$x"_"$a".json > /tmp/dns_update/"$x"_$((a+1)).json
		a=$((a+1))
	done

	aws route53 change-resource-record-sets --hosted-zone-id $HZID --change-batch file:///tmp/dns_update/"$x"_"$a".json
	sleep 5
done
