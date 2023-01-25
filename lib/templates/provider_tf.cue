package templates

provider_tf: out: terraform: required_providers: provider: {
	source:  inputs.provider.identifier
	version: inputs.provider.version
}
