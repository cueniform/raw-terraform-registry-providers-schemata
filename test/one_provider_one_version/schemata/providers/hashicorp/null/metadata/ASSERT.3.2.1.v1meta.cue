package v1

import (
	"strings"
)

"3.2.1": {
	provider: "hashicorp/null"
	version:  "3.2.1"
	created: {
		at: =~"^202"
		by: {
			terraform: {
				terraform_version: =~"1.3."
				platform:          "linux_amd64"
				provider_selections: "registry.terraform.io/hashicorp/null": "3.2.1"
				terraform_outdated: bool
			}
			commit: {
				trigger:      "GITHUB_SHA-is-set-in-test-makefile"
				workflow_sha: "GITHUB_WORKFLOW_SHA-is-set-in-test-makefile"
				workflow_ref: "ENVIRONMENT VARIABLE MISSING"
			}
		}
	}
	contents: {
		raw: {
			filename: "3.2.1.json"
			format:   "json"
			bytes:    "2556"
			sha512:   strings.MinRunes(128) & strings.MaxRunes(128)
			sha512:   "fc5e490c317a7f1c530f26a1db8dcb4a9774bd2fded0136cad2b365de935cd4fd5e98c22e0c08336dd09ac2708052fbfe34aabef949aa887240efc21be1ca4ea"
		}
		compressed: {
			filename: "3.2.1.json.zstd"
			format:   "zstd"
			bytes:    string & =~"^[0-9]+$" & !="0"
			sha512:   strings.MinRunes(128) & strings.MaxRunes(128)
		}
	}
}
