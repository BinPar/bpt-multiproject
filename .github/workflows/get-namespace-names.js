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

const namespaceParts = fileContent
  .split('---')
  .filter(doc => doc.includes('kind: Namespace'));
process.stdout.write(
  namespaceParts
    .map(doc =>
      doc
        .split('\n')
        .map(str => str.trim())
        .find(str => str.startsWith('name:'))
        .split(':')
        .map(str => str.trim())
        .pop(),
    )
    .join(' '),
);
process.exit(0);
