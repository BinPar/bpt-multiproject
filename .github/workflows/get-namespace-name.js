#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const pathToK8sCompiledDir = path.resolve(__dirname, '../../k8s/compiled');
const yamlFileName = fs.readdirSync(pathToK8sCompiledDir)[0];

if (!yamlFileName) {
  console.log(`No YAML file detected in: ${pathToK8sCompiledDir}`);
  process.exit(1);
}

const pathToYamlFile = path.resolve(pathToK8sCompiledDir, yamlFileName);
const fileContent = fs.readFileSync(pathToYamlFile, {
  encoding: 'utf-8',
});

if (!fileContent) {
  console.log(`YAML file has no content. Path: ${pathToYamlFile}`);
  process.exit(1);
}

const namespacePart = fileContent.split('---')[0];
process.stdout.write(
  namespacePart
    .split('\n')
    .map((str) => str.trim())
    .find((str) => str.startsWith('name:'))
    .split(':')
    .map((str) => str.trim())
    .pop(),
);
process.exit(0);
