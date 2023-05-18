#!/bin/sh

for pod in `podman ps --format='{{ .Names }}'`
do
  podman generate systemd --new --name "${pod}" --restart-policy=always > ~/.config/systemd/user/container-"${pod}".service

  podman stop "${pod}"
  podman rm "${pod}"

  systemctl --user enable container-"${pod}".service
  systemctl --user start container-"${pod}".service
  #systemctl --user status container-"${pod}".service
done
