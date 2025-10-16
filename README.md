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

## Adding a new discord server

This will walk through creating a new bridge, likely for a new SIG:
- First thing is to create them a channel in the CompSoc discord if they don't have one already.
- The next step is to add the bot to the new server. Go to the discord developer portal and generate an invite link for them (on the compsoc discord account -- creds are in vaultwarden), oncce they've done this you can proceed to change the credentials.
- Edit the `matterbridge.toml` file to add the following lines:
```toml
[[gateway]]
name="[SIG Name] Bridge Gateway"
enable=true

[[gateway.inout]]
account="discord.compsoc"
channel="ID:1428472587771449405" # <-- ID for the channel in compsoc

[[gateway.inout]]
account="discord.[SIG Name]"
channel="ID:1262394291653836873" # <-- ID for their general channel

[[gateway]]
name="[SIG Name] Announcement Bridge Gateway"
enable=true

[[gateway.out]]
account="discord.compsoc"
channel="ID:1428472587771449405" # <-- ID for the channel in compsoc

[[gateway.in]]
account="discord.[SIG name]"
channel="ID:1266416978898190366" # <-- ID for their announcements channel

[discord.[SIG Name]]

Server="1222930891609866272" # <--- ID for their server
RemoteNickFormat="{NICK}"
# Disable threading, as Webhooks can't reply to threads and it looks off
PreserveThreading=false
# Allow no mentions, since it can be source of spam. Default is all.
AllowMention=[]
# Automatically manage webhooks for Discord channels
AutoWebhooks=true
# Show a preview of other bot's embeds by copying the title and description
ShowEmbeds=true
```
  - Note that the easiest way to get IDs is to just look at the link when visiting through the web portal. It will be in the format `https://discord.com/channels/<server_id>/<channel_id>`
- Then you'll need to add the Token as an environment variable, which can be done by basically setting `$MATTERBRIDGE_DISCORD_[SIG Name]_TOKEN`. If you added it from the same CompSoc Bridge bot, then it'll be the same token as the other SIGs
- You'll also need to reload the container and make sure the secrets are updated on the kubernetes remote

