package schemata

import (
	p_null "cueniform.com/collector/schemata/providers/hashicorp/null/metadata"
	p_random "cueniform.com/collector/schemata/providers/hashicorp/random/metadata"
	p_github "cueniform.com/collector/schemata/providers/integrations/github/metadata"
)

provider: {
	hashicorp: "null":    p_null
	hashicorp: random:    p_random
	integrations: github: p_github
}
