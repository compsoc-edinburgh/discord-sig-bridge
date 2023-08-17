FROM 42wim/matterbridge:stable

COPY .secrets ./.secrets/

RUN export MATTERBRIDGE_DISCORD_COMPSOC_SIGINT_CHANNEL_TOKEN="$(cat .secrets/token.txt)"
RUN export MATTERBRIDGE_DISCORD_SIGINT_GENERAL_CHANNEL_TOKEN="$(cat .secrets/token.txt)"
COPY matterbridge /etc/matterbridge
