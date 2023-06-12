package schemata

import (
	"struct"
)

_providers: {
	_test + _inherited
	_inherited: {
		_errata: 4
		_errata
	}
	_test: 2
}
_cups: 3
_null: 8

provider!: {
	struct.MinFields(_providers)
	struct.MaxFields(_providers)

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
