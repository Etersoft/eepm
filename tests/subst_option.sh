# param true false
subst_option()
{
	eval "[ -n \"\$$1\" ]" && echo "$2" || echo "$3"
}

test1=1
test0=

echo $(subst_option test1 TRUE)
echo $(subst_option test1 TRUE FALSE)
echo $(subst_option test1 "" FALSE)
echo $(subst_option test0 "" FALSE)
echo $(subst_option test0 TRUE)
