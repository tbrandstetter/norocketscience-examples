KEY_FILE="cosign.key"
REGISTRY_ENDPOINT=registry.mgmt.lab.internal
crane auth login ${REGISTRY_ENDPOINT} -u admin -p Harbor12345

for IMAGE in $(cat images.txt)
  do
    NEW_IMAGE="${REGISTRY_ENDPOINT}/${IMAGE#*/}"
    if [[ "$NEW_IMAGE" != *"@sha256:"* ]]; then
      NEW_IMAGE="${NEW_IMAGE}@$(crane --insecure digest $NEW_IMAGE)"
    fi
    docker run --rm -it --net=host \
      -v $PWD:/keys -w /keys \
      -v $HOME/.docker/config.json:/.docker/config.json:ro \
      -e DOCKER_CONFIG=/.docker \
      -e COSIGN_PASSWORD="" \
      -e COSIGN_YES=true \
      --user $(id -u):$(id -g) \
      docker.io/bitnami/cosign:latest \
        sign \
	--allow-insecure-registry \
	--key /keys/$KEY_FILE \
        --tlog-upload=false \
	--use-signing-config=false \
	--new-bundle-format=false \
        $NEW_IMAGE
done