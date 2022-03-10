if [ -z $ARTIFACTORY_USER ]; then
	ARTIFACTORY_USER=`git config user.email`
fi

if [ -z $GIT_REF ]; then
	GIT_REF="HEAD"
fi

if [ -z $ARTIFACTORY_APIKEY ]; then
	echo "ERROR: please define '\$ARTIFACTORY_APIKEY'"
	exit -1
fi

# Single place to define the list of daemons
# Git info on the current commit
GIT_SHA_SHORT=`git rev-parse --short=7 $GIT_REF`
GIT_DESCRIBE=`git describe --abbrev=7 $GIT_REF || echo ""`

# Check if it's release ref
__TMP_IS_RELEASE=`git describe --exact-match $GIT_REF 2> /dev/null || /bin/true`
IS_RELEASE=1
if [ "$__TMP_IS_RELEASE" == "" ]; then
	IS_RELEASE=0
fi

