#!/bin/sh

checkImage() {
  IMAGE_NAME=$(podman inspect --format '{{ .ImageName }}' "${1}")
  #echo "Call image ${IMAGE_NAME} with ${1}"

  if [ $( echo "${IMAGE_NAME}" | grep localhost | wc -l ) -eq 0 ]; then
    podman pull "${IMAGE_NAME}" > /dev/null 2>&1
  fi

  IMAGE_DIGEST=$(podman image inspect --format='{{ .Id }}' "${IMAGE_NAME}" | tr -d '"')
  INSTANCE_DIGEST=$(podman inspect --format='{{ .Image }}' "${1}" | tr -d '"')
  test "${IMAGE_DIGEST}" = "${INSTANCE_DIGEST}"

  return $?
}

for pod in `podman ps --format='{{ .Names }}'`
do
   checkImage "${pod}"
   if [ "$?" -ne "0" ]; then
     echo "Update ${pod}"
     CMD=$(podman inspect --format '{{ .Config.CreateCommand }}' "${pod}" | tr -d '[]')
     #echo "${CMD}"
     eval "${CMD}"
   fi
done

# Cleaning up ... if needed
#echo "Pruning images, volumes, nets"
#podman system prune -a -f --volumes
