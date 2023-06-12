package schemata

import (
	"struct"
)

_cups: 3
_null: 8

provider!: {
	"registry.terraform.io/hashicorp/hashicups"!: {
		struct.MinFields(_cups)
		struct.MaxFields(_cups)
		"0.3.0"!: {
			error!: "this version is omitted intentionally to test errata handling"
		}
	}

	"registry.terraform.io/hashicorp/null"!: {
		struct.MinFields(_null)
		struct.MaxFields(_null)
	}
}
