# CompSoc <-> SIGs Discord Bridge

This is a CompSoc Service that runs an instance of [MatterBridge](https://github.com/42wim/matterbridge) to relay messages bidirectionally between the CompSoc central Discord server and the various SIG Discord servers.

The service is hosted on the [CompSoc k8s cluster](https://github.com/compsoc-edinburgh/CompSoc-k8s/tree/master/services/discord-sig-bridge). On every GitHub push, a Docker image is rebuilt and pushes it to ghcr. 

The server/channel configuration is in the `matterbridge.toml` file.

The bot token is not stored in this repository, please acquire it through other means.

## Basic Modification

To edit the bridges behavior (i.e. don't need to change the tokens at all):
- Make changes to `matterbridge.toml` file
- Push to repository, which will kickoff a pipeline to build and upload to ghcr
- Go into kubernetes and apply the deployment again with: `kubectl rollout restart deployment discord-sig-bridge`

To edit the bridges secrets you'll need to edit the secrets in kubernetes. See the [CompSoc k8s cluster repo](https://github.com/compsoc-edinburgh/CompSoc-k8s/tree/master/services/discord-sig-bridge).

