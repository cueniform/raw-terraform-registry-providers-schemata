package desiderata

import (
	"strconv"
	"list"
	"strings"
)

address: string @tag(address)
address: =~"^.+/.+/.+$"

versions: [...#version]
#version: X={
	version: string

	protocols: [...#protocol]
	#protocol: string

	platforms: [...#platform]
	#platform: {
		os:   string
		arch: string
	}

	new: {
		protocols: {
			to_float: [
				for k in X.protocols {
					*strconv.ParseFloat(k, 64) | 1.0
				}]
			max: *list.Max(new.protocols.to_float) | 1.0
		}
	}
}

out: {
	as_list: [
		for v in versions
		if v.new.protocols.max >= 5.0 {
			"\(address) \(v.version)"
		},
	]
	as_string: strings.Join(as_list, "\n")
}
