package metadata

import (
	"struct"
)

#d: "[0-9]{2}"

input: {
	now:       =~"^20\(#d)-\(#d)-\(#d)T\(#d):\(#d):\(#d)\\+\(#d):\(#d)$" @tag(now)
	commit_id: string                                                    @tag(commit_id)
	terraform: {
		provider_selections: {
			[string]: string
			struct.MaxFields(1)
		}
		terraform_version:  string
		platform:           string
		terraform_outdated: bool
	}
	raw_size:     string @tag(raw_size)
	raw_hash_md5: string @tag(raw_hash_md5)
	raw_filename: string @tag(raw_filename)
	zst_size:     string @tag(zst_size)
	zst_hash_md5: string @tag(zst_hash_md5)
	zst_filename: string @tag(zst_filename)
}

out: {
	for provider_address, provider_version in input.terraform.provider_selections {
		provider: (provider_address): (provider_version): {
			generated: {
				at: input.now
				by: {
					terraform: {
						version:  input.terraform.terraform_version
						platform: input.terraform.platform
						provider: address: provider_address
						provider: version: provider_version
					}
					commit: id: input.commit_id
				}
			}
			content: {
				uncompressed: {
					file:  input.raw_filename
					bytes: input.raw_size
					hash: md5: input.raw_hash_md5
				}
				compressed: {
					file:  input.zst_filename
					bytes: input.zst_size
					hash: md5: input.zst_hash_md5
				}
			}
			error: *null | string
		}
	}
}
