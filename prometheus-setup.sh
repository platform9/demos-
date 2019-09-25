#!/bin/bash

echo
echo " #################################"
echo " ### Prometheus-Kafka Demo Setup ###"
echo " #################################"
echo

read -p "The following will install several components of prometheus with Kafka, dou want to continue? (y/n)" -n1 -s c
if [ "$c" = "y" ]; then

sleep 1

echo "Adding incubator charts repo"

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo add bitnami https://charts.bitnami.com/bitnami
helm update
helm init --upgrade
helm init

sleep 1

echo "Creating developers namespace"

kubectl create namespace developers

sleep 1

echo "Creating prometheus Service Account"

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/prometheus-rbac-clusterrole.yaml

echo "Deploying default storage class for Kafka"

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/sc-standard.yaml

echo "Deploying persistent volume claims for Kafka"

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/pvc-kafka-0.yaml
kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/pvc-kafka-1.yaml
kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/pvc-kafka-2.yaml
kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/pvc-kafka-zookeeper-0.yaml
kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/pvc-kafka-zookeeper-1.yaml
kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/pvc-kafka-zookeeper-2.yaml

sleep 1

echo "Deploying Kafka..."

helm install --namespace developers --name kafka --set metrics.jmx.enabled=true,metrics.kafka.enabled=true,persistence.size=40Gi bitnami/kafka

echo "Waiting several seconds..."
sleep 3

echo "Deploying jmx exporter for Kafka to begin exposing metrics to Prometheus instance..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/svc-jmx-exporter.yaml

echo "Installing Prometheus now..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/prometheus.yaml

echo "Deploying Service Monitor for kafka-prometheus metrics..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/kafka-svc-mon.yaml

echo "Creating a service for the Prometheus UI"

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/kafka-sm-service.yaml

echo "Deploying Grafana via helm chart..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/grafana.yaml

sleep 1

echo "Exposing grafana UI over cloud loadbalancer..."

sleep 1

kubectl expose deployment grafana -n developers --type=LoadBalancer --port=9000 --target-port=9000

kubectl get services -n developers

echo "Go to the Prometheus UI and confirm targets are coming through under 'Service Discovery'"

sleep 5

echo "...You can also now proceed to the Grafana UI and add the prometheus external IP to the targets for data discovery!"

fi
