package schemata

import (
	"cueniform.com/collector/errata/automata:errata"
)

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
