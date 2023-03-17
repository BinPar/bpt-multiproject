load("@ytt:data", "data")
load("@ytt:struct", "struct")
load("@ytt:assert", "assert")

if not data.values.projectName.islower():
  assert.fail("projectName should be a non-empty lowercased string")
end
if not data.values.resourceType:
  assert.fail("resourceType should be a non-empty string")
end
if not (data.values.resourceType == "Deploy" or data.values.resourceType == "Job" or data.values.resourceType == "CronJob"):
  assert.fail("resourceType should be 'Deploy', 'Job' or 'CronJob'")
end
if not (data.values.environment == "test" or data.values.environment == "pre-release" or data.values.environment == "release"):
  assert.fail("environment should be 'test', 'pre-release' or 'release'")
end
if data.values.resourceType == "CronJob" and not data.values.schedule:
  assert.fail("You should specify a 'schedule' when 'resourceType' is CronJob")
end
if data.values.hasIngress == None:
  assert.fail("hasIngress should be specify")
end
if data.values.useHttp == None:
  assert.fail("useHttp should be specify")
end

def namespaceName(project):
  if project == "read-garden":
    return project+"-"+data.values.environment
  end
  if data.values.namespace:
    return data.values.namespace+"-"+project+"-"+data.values.environment
  end
  return data.values.projectName+"-"+project+"-"+data.values.environment
end

def deployName():
  return "deploy-"+data.values.projectName
end

def jobName():
  return "job-"+data.values.projectName
end

def cronJobName():
  return "cron-job-"+data.values.projectName
end

def serviceName():
  return "service-"+data.values.projectName
end
def externalServiceName(service):
  return "service-"+service
end
def ingressName():
  return "ingress-"+data.values.projectName+"-"+data.values.environment
end

def imageName():
  return "402083338966.dkr.ecr.eu-west-1.amazonaws.com/"+data.values.projectName+":"+data.values.environment
end

def certificateName():
  return "cert-"+data.values.projectName
end

def defaultConfigMapName():
  return "default-conf-"+data.values.projectName
end

def isRelease():
  return data.values.environment == "release"
end

def isTest():
  return data.values.environment == "test"
end

def defaultLabels(instance, project):
  return { 'app.kubernetes.io/name': data.values.projectName, 'app.kubernetes.io/instance': instance, 'app.kubernetes.io/environment': data.values.environment, 'app.kubernetes.io/project': project }
end

def defaultHostname(project):
  prefix = project
  if project == "read-garden":
    prefix = "*"
  end
  if isRelease():
    productionDomains = struct.decode(data.values.productionDomains)
    if data.values.productionDomains and productionDomains.get(project):
      return productionDomains[project]
    end
    if data.values.productionDomain:
      return prefix+data.values.productionDomain
    else:
      return prefix+"." + data.values.defaultRootDomain
    end
  else:
    testDomains = struct.decode(data.values.testDomains)
    if isTest() and testDomains and testDomains.get(project):
      return testDomains[project]
    end
    if project == "read-garden":
      return prefix+"."+data.values.environment+"." + data.values.defaultRootDomain
    end
    return prefix+"-"+data.values.environment+"." + data.values.defaultRootDomain
  end
end

def replaceDefaultServiceNameInRules(rules):
  rulesDict = struct.decode(rules)
  for rule in rulesDict:
    if rule.get('http') and rule["http"].get('paths'):
      for path in rule["http"]["paths"]:
        if path.get('backend') and path["backend"].get('serviceName') and path["backend"]["serviceName"].find("##DEFAULT_SERVICE_NAME") > -1:
          path["backend"]["serviceName"] = serviceName()
        end
      end
    end
  end
  return rulesDict
end

def recursiveLookupForStringAndReplace(obj, lookupString, newValue):
  if (type(obj) == "string"):
    return obj.replace(lookupString, newValue)
  end
  if (type(obj) == "struct"):
    obj = struct.decode(obj)
  end
  if type(obj) == "list":
    return [recursiveLookupForStringAndReplace(item, lookupString, newValue) for item in obj]
  end
  if type(obj) == "dict":
    return { key: recursiveLookupForStringAndReplace(value, lookupString, newValue) for key, value in obj.items() }
  end
  return obj
end

def getResourcesForProject(project):
  resourcesByProject = struct.decode(data.values.resourcesByProject)
  result = dict(baseReplicas=2, releaseFactorReplicas=2.0, baseRAMRequest=64, releaseFactorRAMRequest=2.0, baseRAMLimit=128, releaseFactorRAMLimit=2.0, baseCPURequest=30, releaseFactorCPURequest=1.0, baseCPULimit=80, releaseFactorCPULimit=2.0, baseRevisionHistoryLimit=1, releaseFactorHistoryLimit=3.0)
  if resourcesByProject and resourcesByProject.get(project):
    result.update(resourcesByProject[project])
  end
  return struct.encode(result)
end

utils = struct.make(recursiveLookupForStringAndReplace=recursiveLookupForStringAndReplace, cronJobName=cronJobName, jobName=jobName, replaceDefaultServiceNameInRules=replaceDefaultServiceNameInRules, certificateName=certificateName, defaultConfigMapName=defaultConfigMapName, imageName=imageName, isRelease=isRelease, deployName=deployName, serviceName=serviceName, externalServiceName=externalServiceName, ingressName=ingressName, defaultLabels=defaultLabels, defaultHostname=defaultHostname, namespaceName=namespaceName, getResourcesForProject=getResourcesForProject)