# CompSoc <-> SIGs Discord Bridge

This is a [CompSoc Service](https://github.com/compsoc-edinburgh/deployment) that runs an instance of [MatterBridge](https://github.com/42wim/matterbridge) to relay messages bidirectionally between the CompSoc central Discord server and the various SIG Discord servers.

The service is hosted on `deployment-host`, as a Docker container. On every GitHub push, a Docker image is rebuilt and automatically triggers a re-deployment via a webhook.

The server/channel configuration is in the `matterbridge.toml` file.

The bot token is not stored in this repository, please acquire it through other means.

## Basic Modification

All edits to the matterbridge TOML config except for the Token/secrets modification, can be done via commits and push -- the CI will take care of redeployment as long as there is an existing Docker container on the remote (i.e. someone ran `make restart` once upon a time)

## Changing Bot token / First Local Setup

1. Clone the repository
2. (Make sure that there is at least one past GitHub action run -- we need at least one Docker image created.)
3. Run `make initialise` to create a local `.secrets` directory.
4. Create a `.secrets/.env` file containing the following:

```
MATTERBRIDGE_DISCORD_COMPSOC_TOKEN=<DISCORD BOT TOKEN>
MATTERBRIDGE_DISCORD_SIGINT_TOKEN=<DISCORD BOT TOKEN>
MATTERBRIDGE_DISCORD_GAMEDEVSIG_TOKEN=<DISCORD BOT TOKEN>
```

This file is passed as the `--env-file` argument when starting the Docker container. MatterBridge will automatically treat them as the Token fields for the TOML config dicts like: `[discord.compsoc]`

5. Run `make restart`, which will stop the remote service if running, sync the .env file to it, and start the remote service with the secrets.
