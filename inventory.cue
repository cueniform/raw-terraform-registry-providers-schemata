package schemata

import "strings"

provider: _

// the schemata we already possess
inventory: {
	text: strings.Join([
		for address, versions in provider
		for version, schema in versions
		let X = schema.generated.by.terraform.provider {
			"\(X.address) \(X.version)"
		},
	], "\n")
}
