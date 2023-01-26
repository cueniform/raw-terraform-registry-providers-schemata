package metadata

inputs: {
	provider: {
		//version:    string @tag(provider_version)
		identifier: string @tag(provider_identifier)
	}
}

package_file: out: """
package metadata

import "cueniform.com/collector/schemata/providers/\(inputs.provider.identifier)/metadata:v1"

v1
"""
