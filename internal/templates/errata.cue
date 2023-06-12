package templates

errata: {
	_address: string @tag(address)
	_version: string @tag(version)
	_error:   string @tag(error)
	(_address):
		(_version):
			_error
}
