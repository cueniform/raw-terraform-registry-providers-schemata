default: process

download:
	for I in 1 2 3 ; do curl "https://registry.terraform.io/v2/providers?filter%5Btier%5D=partner&page%5Bnumber%5D=$$I&page%5Bsize%5D=500&sort=-featured%2Ctier%2Cname" \
	> page.$$I.json; done

process:
	cue import page.1.json -l 'page1:' --package tfapi --force
	cue import page.2.json -l 'page2:' --package tfapi --force
	cue import page.3.json -l 'page3:' --package tfapi --force

top-%:
	cue export -t topN="$*"      -e downloads.top.as_string  --out text

over-%:
	cue export -t downloads="$*" -e downloads.over.as_string --out text
