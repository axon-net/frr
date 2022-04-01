<p align="center">
<img src="http://docs.frrouting.org/en/latest/_static/frr-icon.svg" alt="Icon" width="20%"/>
</p>

Palmetto FRR
=========
In order to generate new docker images, a new commit *MUST* include some changes in the artifactory-ibm/frr_docker_version.sh


- If the docker image with tag compose as frr:"$FRR_UBI"-"$FRR_COMMIT_HASH"-"$FRR_SERIAL" already exists nothing is going to be generated.

- The hash will be point to the last commit by means of "git rev-parse HEAD" command.

- The FRR_SERIAL _MUST_ be incremented by 1, so in that way we'll know easily which images should pick.

