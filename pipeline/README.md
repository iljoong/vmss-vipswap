## Sample Pipelines

### Variables Group for pipeline

- `azure_build` variables group:
```
  buildConfiguration: 'Release'
  blobaccount: 'vmssblobacct'
  container: 'app'
  imagename: 'app$(Build.BuildId)'
  rgname: 'vmss-image-rgname'
```

- `azure_subscription` variables group:
```
  subscription_id: ''
```

### Build pipeline

- `build-blobcp-pipeline.yml`: build pipeline with blob copy instead of winrm file copy
- `build-filecp-pipeline.yml`: build pipeline with winrm file copy (basic)

### Release Pipeline

- `release-appgw-pipeline.yml`: release pipeline with Application Gateway as public load balancer
- `release-plb-pipeline.yml`: release pipeline with public load balancer (basic)
