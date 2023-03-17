#!/bin/bash

namespaces=$1
teams=$2
repoOwner=$3
for team in $teams; do
  for namespace in $namespaces; do
    kubectl create rolebinding $team-read-all --group="$repoOwner:$team" --clusterrole=cluster-read-all -n $namespace --save-config --dry-run=client -o yaml | kubectl apply -f -
  done
  kubectl create clusterrolebinding $team-read-ns --group="$repoOwner:$team" --clusterrole=cluster-read-namespaces --save-config --dry-run=client -o yaml | kubectl apply -f -
done
