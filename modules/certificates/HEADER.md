## Terraform docs

[Terraform Docs](https://terraform-docs.io/) created by running the following
from the root of the repository:

```Shell
podman run --rm -u $(id -u) \
    --volume "$(pwd):/terraform-docs" \
    -w /terraform-docs \
    quay.io/terraform-docs/terraform-docs:latest \
    --output-file README.md \
    --output-mode inject /terraform-docs/modules/certificates
```
