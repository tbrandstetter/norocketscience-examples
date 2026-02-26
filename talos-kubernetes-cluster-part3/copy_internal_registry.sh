REGISTRY_ENDPOINT=registry.mgmt.lab.internal
crane auth login ${REGISTRY_ENDPOINT} -u admin -p Harbor12345
for SOURCE_IMAGE in $(cat images.txt)
  do
    IMAGE_WITHOUT_DIGEST=${SOURCE_IMAGE%%@*}
    IMAGE_WITH_NEW_REG="${REGISTRY_ENDPOINT}/${IMAGE_WITHOUT_DIGEST#*/}"
    crane --insecure copy \
      $SOURCE_IMAGE \
      $IMAGE_WITH_NEW_REG
done