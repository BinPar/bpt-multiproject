#!/bin/bash

environments=$1
cd ./k8s/templates
for environment in $environments
do
  kubectl apply -f ../compiled/$environment.yml
done
