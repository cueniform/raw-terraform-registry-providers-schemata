package templates

provider_tf: out: terraform: required_providers: provider: {
	source:  string @tag(address)
	version: string @tag(version)
}
