BEGIN {
	prev=""; pri=0
}
{
	cur=$1
}
prev==cur {
	pri++
}
prev!=cur {
	prev=cur
	pri=0
}
{
	print $0, pri
}
