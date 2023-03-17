#!/bin/bash

aws ecr describe-repositories --repository-names $1 2>&1 > /dev/null
status=$?
if [[ ! "${status}" -eq 0 ]]; then
    aws ecr create-repository --repository-name $1
    aws ecr put-lifecycle-policy --repository-name $1 --lifecycle-policy-text '{"rules":[{"rulePriority":1,"description":"No untagged images","selection":{"tagStatus":"untagged","countType":"sinceImagePushed","countUnit":"days","countNumber":1},"action":{"type":"expire"}},{"action":{"type":"expire"},"selection":{"countType":"imageCountMoreThan","countNumber":1,"tagStatus":"tagged","tagPrefixList":["latest"]},"description":"No more than one latest","rulePriority":2},{"action":{"type":"expire"},"selection":{"countType":"imageCountMoreThan","countNumber":1,"tagStatus":"tagged","tagPrefixList":["prerelease"]},"description":"No more than one pre-release","rulePriority":3},{"action":{"type":"expire"},"selection":{"countType":"imageCountMoreThan","countNumber":1,"tagStatus":"tagged","tagPrefixList":["release"]},"description":"No more than one release","rulePriority":4},{"rulePriority":5,"description":"No more than 5 extra images","selection":{"tagStatus":"any","countType":"imageCountMoreThan","countNumber":8},"action":{"type":"expire"}}]}'
fi
