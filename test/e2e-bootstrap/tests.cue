package tests

import (
	"struct"
)

provider: _

before: {
	definition: provider: content & constraints
	content: {
		"registry.terraform.io/hashicorp/oraclepaas": {
			"1.5.2": {
				error: "excluded from download during tests"
			}
		}
		"registry.terraform.io/hashicorp/template": {
			"2.1.0": {// by fixing this, we assert that the schema generation didn't overwrite the file
				generated: {
					at: "2023-06-14T16:51:29+00:00"
					by: terraform: version: "1.4.6"
					by: terraform: provider: address: "registry.terraform.io/hashicorp/template"
					by: terraform: provider: version: "2.1.0"
				}
				content: uncompressed: file: "registry.terraform.io_hashicorp_template_2.1.0.json"
				content: compressed: hash: md5: "dba9784fc1ef5d1608591937b72cf490"
				error: null
			}
		}
	}
	constraints: {
		"registry.terraform.io/hashicorp/oraclepaas": struct.MinFields(1)
		"registry.terraform.io/hashicorp/oraclepaas": struct.MaxFields(1)
		"registry.terraform.io/hashicorp/template":   struct.MinFields(1)
		"registry.terraform.io/hashicorp/template":   struct.MaxFields(1)
	}
}

after_2_schemata_downloads: {
	definition: provider: content & constraints
	content: before.content & {
		"registry.terraform.io/hashicorp/template": "2.2.0": error!:   null
		"registry.terraform.io/hashicorp/oraclepaas": "1.5.3": error!: null
	}
	constraints: {
		"registry.terraform.io/hashicorp/oraclepaas": struct.MinFields(2)
		"registry.terraform.io/hashicorp/oraclepaas": struct.MaxFields(2)
		"registry.terraform.io/hashicorp/template":   struct.MinFields(2)
		"registry.terraform.io/hashicorp/template":   struct.MaxFields(2)
	}
}

after_4_schemata_downloads: {
	definition: provider: content & constraints
	content: after_2_schemata_downloads.content & {
		"registry.terraform.io/hashicorp/template": "2.1.1": error!: null
		"registry.terraform.io/hashicorp/template": "2.1.2": error!: null
	}
	constraints: {
		"registry.terraform.io/hashicorp/oraclepaas": struct.MinFields(2)
		"registry.terraform.io/hashicorp/oraclepaas": struct.MaxFields(2)
		"registry.terraform.io/hashicorp/template":   struct.MinFields(4)
		"registry.terraform.io/hashicorp/template":   struct.MaxFields(4)
	}
}
