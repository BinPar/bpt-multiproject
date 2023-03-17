#!/bin/bash

namespace=$1
teams=$2
repoOwner=$3
for team in $teams; do
  kubectl create rolebinding $team-read-all --group="$repoOwner:$team" --clusterrole=cluster-read-all -n $namespace --save-config --dry-run=client -o yaml | kubectl apply -f -
done
