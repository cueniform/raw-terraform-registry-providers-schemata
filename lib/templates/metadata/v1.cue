package v1

#FSString: string | *"INPUT FILE MISSING"

metadata: {
	input: {
		terraform: terraform_version: #FSString
		provider_version:             #FSString
		provider_identifier:          #FSString
		timestamp:                    #FSString
		schema_raw_sha512:            #FSString
		schema_compressed_sha512:     #FSString
		schema_compressed_format:     #FSString
		schema_compressed_size_bytes: #FSString
		schema_raw_size_bytes:        #FSString
		env_GITHUB_SHA:               #FSString
		env_GITHUB_WORKFLOW_SHA:      #FSString
		env_GITHUB_WORKFLOW_REF:      #FSString
		schema_raw_filename:          #FSString
		schema_compressed_filename:   #FSString
	}

	out: {
		"\(input.provider_version)": {
			provider: input.provider_identifier
			version:  input.provider_version
			created: {
				at: input.timestamp
				by: {
					terraform: input.terraform
					commit: {
						[string]:     !=""
						trigger:      *input.env_GITHUB_SHA | "ENVIRONMENT VARIABLE MISSING"
						workflow_sha: *input.env_GITHUB_WORKFLOW_SHA | "ENVIRONMENT VARIABLE MISSING"
						workflow_ref: *input.env_GITHUB_WORKFLOW_REF | "ENVIRONMENT VARIABLE MISSING"
					}
				}
			}
			contents: {
				raw: {
					filename: input.schema_raw_filename
					format:   input.schema_raw_format
					bytes:    input.schema_raw_size_bytes
					sha512:   input.schema_raw_sha512
				}
				compressed: {
					filename: input.schema_compressed_filename
					format:   input.schema_compressed_format
					bytes:    input.schema_compressed_size_bytes
					sha512:   input.schema_compressed_sha512
				}
			}
		}
	}
}
