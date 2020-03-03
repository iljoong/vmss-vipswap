## Packer Sample

- `packer.json`: simple packer script
- `packer_blob.json`: use blob to upload/download large file transfer instead of `file provisioner`. see [packer document](https://packer.io/docs/provisioners/file.html#slowness-when-transferring-large-files-over-winrm-)
- `packer_imgage.json`: use customer base image instead of platform image