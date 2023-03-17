#!/bin/bash

environments=$1
cd ./k8s/templates
./compile-templates.sh "$environments"
