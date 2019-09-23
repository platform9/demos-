
echo
echo " #################################"
echo " ### Prometheus-Kafka Demo Setup ###"
echo " #################################"
echo

read -p "The following will install several components of prometheus with Kafka, dou want to continue? (y/n)" -n1 -s c
if [ "$c" = "y" ]; then

sleep 1

echo "adding incubator charts repo"

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm init
helm update

sleep 1

echo "Creating developers namespace"

kubectl create namespace developers

echo "Deploying default storage class for Kafka"

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/sc-standard.yaml

echo "Deploying Kafka..."

helm install --namespace developers --name kafka --set prometheus.jmx.enabled=true,prometheus.kafka.enabled=true,persistence.size=40Gi incubator/kafka

echo "Waiting several seconds..."
sleep 3

echo "Installing Prometheus now..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/prometheus.yaml

echo "Deploying jmx exporter for Kafka to begin exposing metrics to Prometheus instance..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/svc-jmx-exporter.yaml

echo "Deploying Service Monitor for kafka-prometheus metrics..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/kafka-svc-mon.yaml

echo "Deploying Grafana via helm chart..."

kubectl create -f https://raw.githubusercontent.com/platform9/prometheus-kafka/master/grafana.yaml

sleep 1

echo "Exposing grafana UI over cloud loadbalancer..."

sleep 1

kubectl expose deployment grafana -n developers --type=LoadBalancer --port=9000--target-port=9000

echo "Exposing Prometheus over cloud loadbalancer to verify kafka targets under service discovery in Prometheus UI"

sleep 1

kubectl expose prometheus kafka-watcher -n developers --type=LoadBalancer --port=9090 --target-port=9090

sleep 1

kubectl get services -n developers

echo "Go to the Prometheus UI and confirm targets are coming through under 'Service Discovery'"

sleep 1

echo "...Proceed to the Grafana UI and add the prometheus external IP to the targets for data discovery!"

fi
