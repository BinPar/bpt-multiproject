#!/bin/bash

namespace=$1
projectName=$2
environment=$3
deployName=$(kubectl -n $namespace get deploy -l "app.kubernetes.io/name=$projectName,app.kubernetes.io/instance=deploy,app.kubernetes.io/environment=$environment" -o name)
if [ -z "$deployName" ]; then
    echo "Deploy for project $projectName in namespace $namespace and environment $environment not found!"
    exit 1
fi
kubectl -n $namespace patch $deployName -p "{ \"spec\": { \"template\": { \"metadata\": { \"labels\": { \"ci-cd-update\": \"`date +'%s'`\" } } } } }"
