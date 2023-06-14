package tfapi

import (
	"list"
	"strings"
)

stats: [
	for input in [page1, page2, page3]
	for v in input.data {
		{
			address: "registry.terraform.io/" + strings.ToLower(v.attributes."full-name")
			count:   v.attributes.downloads
		}
	},
]

#ListToString: {
	#list: [...]
	#field: string
	strings.Join([
		for v in #list {v[#field]},
	], "\n")
}

sorted: {
	as_list:   list.Sort(stats, {x: {}, y: {}, less: x.count > y.count})
	as_string: strings.Join(
			[
				for v in as_list {"\(v.address) \(v.count)"},
			], "\n")
}

minimum: int @tag(downloads,type=int)
minimum: *0 | int
topN:    int @tag(topN,type=int)
topN:    *10 | int

downloads: {
	over: {
		as_list: [
			for v in sorted.as_list
			if v.count > minimum {v},
		]
		as_string: #ListToString & {#list: downloads.over.as_list, #field: "address", _}
	}
	top: {
		as_list:   list.Slice(sorted.as_list, 0, topN-1)
		as_string: #ListToString & {#list: as_list, #field: "address", _}
	}
}
