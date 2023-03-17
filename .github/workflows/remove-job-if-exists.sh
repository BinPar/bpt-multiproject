#!/bin/bash

namespaces=$1
projectName=$2
environment=$3
for namespace in $namespaces; do
    deployNames=$(kubectl -n $namespace get job -l "app.kubernetes.io/name=$projectName,app.kubernetes.io/instance=job,app.kubernetes.io/environment=$environment" -o name)
    if [ -z "$deployNames" ]; then
        echo "Jobs for project $projectName in namespace $namespace and environment $environment not found! Just skip!"
        exit 0
    fi
    for deployName in $deployNames; do
        kubectl -n $namespace delete $deployName
    done
done
