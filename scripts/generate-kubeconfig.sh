#!/usr/bin/env bash

set -e


### These are the parameters you can set when calling this script:
NAMESPACE="${NAMESPACE:-default}"
###

echo "⏳ Adding Kubernetes API server to kubectl configuration..."
KUBECONFIG_SERVER=$(kubectl config view --minify --output go-template='{{ (index .clusters 0).cluster.server }}')
kubectl config view --minify --raw --output go-template='{{ index ((index .clusters 0).cluster) "certificate-authority-data" }}' | base64 --decode > /tmp/kubeconfig-ca.crt
kubectl --kubeconfig /tmp/kubeconfig.yml config set-cluster production --server=$KUBECONFIG_SERVER --certificate-authority /tmp/kubeconfig-ca.crt --embed-certs=true
rm /tmp/kubeconfig-ca.crt
echo "✅ Kubernetes API server added."
echo

echo "⏳ Adding authentication token to kubectl configuration..."
KUBECONFIG_TOKEN=$(kubectl create token github-actions --namespace "${NAMESPACE}")
kubectl --kubeconfig /tmp/kubeconfig.yml config set-credentials github-actions --token $KUBECONFIG_TOKEN
kubectl --kubeconfig /tmp/kubeconfig.yml config set-context github-actions-production --cluster production --user github-actions --namespace "${NAMESPACE}"
kubectl --kubeconfig /tmp/kubeconfig.yml config use-context github-actions-production
echo "✅ Authentication token added."
echo

echo "⏳ Converting configuration to base64..."
KUBECONFIG_B64="$(base64 -w0 /tmp/kubeconfig.yml)"
rm /tmp/kubeconfig.yml
echo "✅ Configuration converted."
echo

echo "👌 Configuration file ready!"
echo "👇 Use the following value for your GitHub secret:"
echo
echo "${KUBECONFIG_B64}"
echo
