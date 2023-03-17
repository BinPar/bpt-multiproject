#!/bin/bash

namespace=$1
projectName=$2
environment=$3
deployName=$(kubectl -n $namespace get job -l "app.kubernetes.io/name=$projectName,app.kubernetes.io/instance=job,app.kubernetes.io/environment=$environment" -o name)
if [ -z "$deployName" ]; then
    echo "Job for project $projectName in namespace $namespace and environment $environment not found! Just skip!"
    exit 0
fi
kubectl -n $namespace delete $deployName
