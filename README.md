# Apache Ignite on Azure AKS Java caching example

This example assumes you already have kubectl, azure-cli (version 2+), maven and JAVA jdk installed.

Usage:

```
$ az login #authenticate with Azure from your CLI
$ make create-azure-k8s #create AKS cluster
$ make ignite-deploy-k8s #deploy Apache Ignite cluster to K8S
$ make ignite-activate-cluster
$ make build #build Java example
$ make run
```

To remove everything:

```
$ make azure-delete-cluster
$ make azure-delete-resourcegroup
```