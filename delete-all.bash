#!/bin/bash

# delete all pods
kubectl delete --all pods --namespace=default

# deete all deployments
kubectl delete --all deployments --namespace=default
 
# delete all services
kubectl delete --all services --namespace=default
 
# delete all configmaps
kubectl delete --all configmaps --namespace=default

# delete all persistent volumes
kubectl delete pvc --all --namespace=default

