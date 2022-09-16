## Packer Sample

> This sample build an VM image with '2019-Datacenter-Core-with-Containers-smalldisk' base image and 'dotnet 6.0' runtime. 

- `packer.json`: simple packer script
- `packer_blob.json`: use blob to upload/download large file transfer instead of `file provisioner`. see [packer document](https://packer.io/docs/provisioners/file.html#slowness-when-transferring-large-files-over-winrm-)
- `packer_imgage.json`: use customer base image instead of platform image

build vm image

```
$ packer build -var rgname=test-vmss -var imagename=webapi001 packer_file.json 
```