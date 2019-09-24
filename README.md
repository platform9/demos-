![alt text](https://raw.githubusercontent.com/platform9/prometheus-kafka/master/kafka_prom_architecture.png)


The following demo deploys a prometheus stack via Kubernetes operators in order to monitor Kafka metrics and visualize them in grafana 

## Pre-Requisities:

1. A Kubernetes cluster of atleast 3 Nodes (1 Master and 2 Workers) 
2. EBS Storage for persistent volume claims and dynamic provisioning on storage class 
3. Prometheus operator enabled on PMK cluster via the "infrastructure" tab 
4. Helm and Tiller installed 

## Instructions 

Download the prometheus-setup.sh and run the script. Afterwards, confirm that the targets are showing for Kafka exported metrics under service discovery in the prometheus UI 
You can then go to Grafan Dashboard and add the external IP for prometheus in order to begin visualizing the data

Enjoy!
-Platform9
