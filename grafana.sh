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
