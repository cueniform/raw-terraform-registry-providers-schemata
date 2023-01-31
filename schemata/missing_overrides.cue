package missing

// These are versions we want to pretend we already possess, stopping the
// fetcher from retrieving them.

collected: {
	"integrations github 4.27.0": "https://github.com/integrations/terraform-provider-github/issues/1236"
	"integrations github 4.27.1": "https://github.com/integrations/terraform-provider-github/issues/1236"
	"hashicorp awscc 0.7.0":      "Error while installing hashicorp/awscc v0.7.0: checksum list has unexpected SHA-256 hash"
	"hashicorp awscc 0.0.15":     "failed to retrieve authentication checksums for provider: 404 Not Found returned from releases.hashicorp.com"
	"hashicorp vault 1.9.0":      "registry announces plugin's compatibility with protocol v5, but it only talks v4"
}
