# Cueniform: Raw Terraform Registry Providers Schemata

This repository collects
[schemata](https://developer.hashicorp.com/terraform/cli/commands/providers/schema#format-summary)
emitted by Providers published on the
[Terraform Registry](https://registry.terraform.io).

It collects a single schema for each provider version published, and stores it
as a zstandard-compressed JSON file in `schemata/`.
Associated metadata for each schema is stored in a CUE file in the same
directory, sharing a filename prefix with the version it describes.
The repository may be used as a CUE module, giving access to the
hierarchically-structured CUE metadata but not the schemata contents.

A compressed format is used to store the schemata because the set of providers
this repository tracks is essentially unbounded, and compression lets us fit
more into a "reasonably" sized repository.
Any consumer of this corpus will inherently be "processing" this repository's
files, therefore adding an extra decompression step doesn't seem like too much
of a burden.

This repository's
[automated actions](https://github.com/cueniform/raw-terraform-registry-providers-schemata/actions)
don't process or validate the schemata, and don't (currently) track
representational schema changes across terraform CLI versions.
