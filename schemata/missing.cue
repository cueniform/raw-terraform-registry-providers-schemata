package missing

import (
	"strings"
	"cueniform.com/collector/registry"
	"cueniform.com/collector/schemata"
)

#V4PluginOnly: ["4"]
upstream: {
	for namespace, providers in registry.provider
	for provider, versions in providers
	for version in versions.versions
	for protocol in version.protocols {
		{"\(protocol)": "\(namespace) \(provider) \(version.version)": true}
	}
}

collected: {
	for namespace, providers in schemata.provider
	for provider, versions in providers
	for version, metadata in versions {
		"\(namespace) \(provider) \(version)": true
	}
}

v5v6plugins: {
	if upstream."5.0" != _|_ {
		for p, _ in upstream."5.0" {
			{"\(p)": true}
		}
	}
	if upstream."6.0" != _|_ {
		for p, _ in upstream."6.0" {
			{"\(p)": true}
		}
	}
}

list: [
	for provider, _ in v5v6plugins if (collected[provider] == _|_) {provider},
]
text: strings.Join(list, "\n")
