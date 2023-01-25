package templates

lockfile_hcl: out: """
provider "registry.terraform.io/\(inputs.provider.identifier)" {
  version = "\(inputs.provider.version)"
}

"""
