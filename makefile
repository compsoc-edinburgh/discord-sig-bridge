include .env

REMOTE=root@deployment-host.comp-soc.com

# .SILENT:

tail:
	ssh ${REMOTE} 'docker logs -f --tail 0 service-${SERVICE_NAME}'

logs:
	ssh ${REMOTE} 'docker logs service-${SERVICE_NAME}'

sync-secrets:
	rsync -r ./.secrets/ ${REMOTE}:/secrets/service-${SERVICE_NAME}

generate-port:
	ssh ${REMOTE} 'ruby -e "require \"socket\"; puts Addrinfo.tcp(\"\", 0).bind {|s| s.local_address.ip_port }"' | tr -d '[:space:]' > .open-port

PORT = $(shell cat .open-port)

# Only run once, at service initialisation. All other deployment will be through github actions
initialise: generate-port
	mkdir -p .secrets
	ssh ${REMOTE} "mkdir -p /secrets/service-${SERVICE_NAME}"
	ssh ${REMOTE} 'docker run -d --name service-${SERVICE_NAME} \
		--network traefik-net \
		--label "traefik.enable=true" \
		-p ${PORT}:${PORT} \
		-e PORT=${PORT} \
		-v /secrets/service-${SERVICE_NAME}:/secrets \
		-e "FILE_UPLOAD=https://service-simple-storage:3456/${SERVICE_NAME}" \
		--label "com.centurylinklabs.watchtower.enable=true" \
		ghcr.io/compsoc-edinburgh/service-${SERVICE_NAME}'
	rm .open-port

teardown:
	ssh ${REMOTE} 'docker stop service-${SERVICE_NAME}'
	ssh ${REMOTE} 'docker rm service-${SERVICE_NAME}'
