#!/bin/bash
minikube addons enable ingress
kubectl patch configmap tcp-services -n kube-system --patch '{"data":{"6033":"default/proxysql-cluster:6033"}}'
kubectl patch deployment nginx-ingress-controller --patch "$(cat ./nginx-ingress/nginx-ingress-controller-patch.yaml)" -n kube-system

