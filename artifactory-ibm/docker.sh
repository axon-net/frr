#!/bin/bash

# This script uploads all images on the current
# commit to the docker repository

#set -e


# Import common constants
# GIT_REF and the import, in this order, _must_ be before DOCKER_*
GIT_REF=$3
source $(dirname "$0")/common.sh

DOCKER_USER=$ARTIFACTORY_USER
DOCKER_PWD=$ARTIFACTORY_APIKEY

# Set docker repo
if [ "$IS_RELEASE" == "1" ]; then
	DOCKER_REPO=ccs-mcnm-team-gw-releases-docker-local.artifactory.swg-devops.com
else
	DOCKER_REPO=ccs-mcnm-team-gw-develop-docker-local.artifactory.swg-devops.com
fi

check_perm(){
	if [ "$__ARTIFACTORY_ALLOW_PUSH" != "1" ]; then
		echo "ERROR: you should NOT attempt to do WRITE operations on the remote registry manually. If you know what you are doing, define the env. variable __ARTIFACTORY_ALLOW_PUSH=1"
		exit -1
	fi
}

docker_push_image(){
	docker tag $1 ${DOCKER_REPO}/$1
	docker push ${DOCKER_REPO}/$1
	docker rmi ${DOCKER_REPO}/$1 #remove local tag

	if [ -n "${GIT_DESCRIBE}" ]; then
		docker tag $1 ${DOCKER_REPO}/$1:${GIT_DESCRIBE} 
		docker push ${DOCKER_REPO}/$1:${GIT_DESCRIBE}
		docker rmi ${DOCKER_REPO}/$1:${GIT_DESCRIBE} #remove local tag
	fi
}

docker_pull_image(){
	docker pull ${DOCKER_REPO}/$1
	if [ $? -gt 0 ]; then
		pull_ret=1
	fi
	if [ -n "${GIT_DESCRIBE}" ]; then
		docker pull ${DOCKER_REPO}/$1:${GIT_DESCRIBE}
		if [ $? -gt 0 ]; then
			pull_ret=1
		else
			pull_ret=0
		fi
	fi
}

# Add to frr base image the typical debug,dev tools
docker_tools_image(){
	ARTIFACTORY_PWD=artifactory-ibm
	docker build \
		--build-arg="FROM_IMAGE=$1" \
		--file=$ARTIFACTORY_PWD/toolsDockerfile \
		--tag=$3 \
		$ARTIFACTORY_PWD
}

echo "Using:"
echo "  DOCKER_REPO: '$DOCKER_REPO'"
echo "  DOCKER_USER: '$DOCKER_USER'"
echo "  GIT_SHA_SHORT: '$GIT_SHA_SHORT'"
echo "  GIT_DESCRIBE: '$GIT_DESCRIBE'"

# Login to docker
echo "${DOCKER_PWD}" | docker login "${DOCKER_REPO}"  -u "${DOCKER_USER}" --password-stdin 2>&1

# Exec cmd
case $1 in
	"push")
		check_perm
		# $2==$IMAGE_TAG  $3==$COMMIT_HASH
		docker_push_image $2 $3
		;;
	"pull")
		docker_pull_image $2
		exit $pull_ret
		;;
	"tools")
		# Create $4 tools image FROM $2
		docker_tools_image $2 $3 $4
		exit $pull_ret
		;;
	*)
		echo "ERROR: unknown commmand '$1'"
		exit -1
		;;
esac
