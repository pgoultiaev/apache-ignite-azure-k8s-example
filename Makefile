IGNITE_GITHUB_EXAMPLES_AZ="https://raw.githubusercontent.com/apache/ignite/master/modules/kubernetes/config/az"
RESOURCE_GROUP=ignitegroup
CLUSTER_NAME=ignitecluster


# Azure resource group and AKS cluster setup
create-azure-k8s: azure-resource-group azure-create-cluster azure-remove-k8s-config azure-connect-cluster

azure-resource-group:
	az group create \
	--name $(RESOURCE_GROUP) \
	--location westeurope

azure-create-cluster:
	az provider register \
	--namespace Microsoft.ContainerService
	az aks create \
	--resource-group $(RESOURCE_GROUP) \
	--name $(CLUSTER_NAME) \
	--node-count 3 \
	--enable-addons monitoring \
	--generate-ssh-keys

# remove k8s config to prevent merge conflicts due to re-use of cluster name, this can be improved
azure-remove-k8s-config:
	rm ~/.kube/config

azure-connect-cluster:
	az aks get-credentials \
	--resource-group $(RESOURCE_GROUP) \
	--name $(CLUSTER_NAME)


# Ignite Cluster Deployment to K8S on Azure
ignite-deploy-k8s:
	kubectl apply -f $(IGNITE_GITHUB_EXAMPLES_AZ)/ignite-namespace.yaml
	kubectl apply -f $(IGNITE_GITHUB_EXAMPLES_AZ)/ignite-service-account.yaml
	kubectl apply -f $(IGNITE_GITHUB_EXAMPLES_AZ)/ignite-account-role.yaml
	kubectl apply -f $(IGNITE_GITHUB_EXAMPLES_AZ)/ignite-role-binding.yaml
	kubectl config set-context $$(kubectl config current-context) --namespace=ignite
	kubectl apply -f ignite-deployment.yaml
	kubectl apply -f $(IGNITE_GITHUB_EXAMPLES_AZ)/ignite-service.yaml

# activation of cluster by using kubectl exec. This solution is dirty, but it works.
ignite-activate-cluster:
	kubectl exec -it $$(kubectl get pods -o jsonpath="{.items[?(@.metadata.labels.app=='ignite')].metadata.name}" | cut -d ' ' -f 1) \
	 --namespace=ignite \
	 -- /opt/ignite/apache-ignite-fabric/bin/control.sh --activate


# Use K8S dashboard on Azure
azure-k8s-dashboard-clusterrolebinding:
	kubectl create clusterrolebinding kubernetes-dashboard \
	--clusterrole=cluster-admin \
	--serviceaccount=kube-system:kubernetes-dashboard

azure-k8s-dashboard:
	az aks browse --resource-group $(RESOURCE_GROUP) --name $(CLUSTER_NAME)


# Delete cluster on AKS
azure-delete-cluster:
	az aks delete \
	--name $(CLUSTER_NAME) \
	--resource-group $(RESOURCE_GROUP) \
	--no-wait \
	--yes


# Java project shortcuts
build:
	mvn clean package -f ignite-quickstart/pom.xml

run:
	CLUSTERADDR=$$(kubectl get svc -n ignite -o jsonpath="{.items[].status.loadBalancer.ingress[0].ip}"):10800 \
	java -jar ignite-quickstart/target/ignite-quickstart-1.0-SNAPSHOT.jar
