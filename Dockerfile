FROM 42wim/matterbridge:stable

COPY .secrets ./

RUN export MATTERBRIDGE_DISCORD_COMPSOC_SIGINT_CHANNEL_TOKEN="$(cat .secrets/token.txt)"
COPY matterbridge /etc/matterbridge
