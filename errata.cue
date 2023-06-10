package schemata

errata: {
	"registry.terraform.io/integrations/github": {
		"4.27.0": "https://github.com/integrations/terraform-provider-github/issues/1236"
		"4.27.1": "https://github.com/integrations/terraform-provider-github/issues/1236"
	}
	"registry.terraform.io/hashicorp/awscc": {
		"0.7.0":
			"Error while installing hashicorp/awscc v0.7.0: checksum list has unexpected SHA-256 hash"
		"0.0.15":
			"failed to retrieve authentication checksums for provider: 404 Not Found returned from releases.hashicorp.com"
		"0.0.14":
			"failed to retrieve authentication checksums for provider: 404 Not Found returned from releases.hashicorp.com"
	}
	"registry.terraform.io/hashicorp/vault": {
		"1.9.0": "registry announces plugin's compatibility with protocol v5, but it only talks v4"
	}
}

provider: {
	for provider_address, versions in errata
	for provider_version, problem in versions {
		(provider_address): (provider_version): {
			error: problem
			generated: by: terraform: provider: {
				address: provider_address
				version: provider_version
			}
		}
	}
}
