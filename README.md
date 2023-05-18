# Contribution rules

If you want to contribute to this list, create a PR (Pull Request) with description what you are adding. The following rules should be addressed:

* Clear description
* Keep it simple and stupid (KISS)
* Only use active open-source software and images
* Configuration/Enhancements have to be tested or should be annotated as **NOT TESTED**

**This is an ongoing work and is not yet finished!!**

# Topics
* [Operating systems for RaspberryPi](#os)
* [Configuration and Tweaks](#config)
* [Security](#sec)
* [PaaS](#paas)
* [Images and Container](#container)

# <a id="os">Operating systems</a>
The operating system should be leightweight: No GUI ("headless"), no multimedia stuff, no "fat" applications or services. A good overview is [here](https://www.makeuseof.com/tag/lightweight-operating-systems-raspberry-pi/).

# <a id="config">Configuration for OS'es</a>
## Raspbian / Debian / DietPI
* In file */boot/cmdline.txt* add *cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1* into the end of the file. (see: https://www.padok.fr/en/blog/raspberry-kubernetes)
* For Apparmor insert *lsm=apparmor* to */boot/cmdline.txt* (https://forums.raspberrypi.com/viewtopic.php?t=66748#p1834603)
* For better IRQ handling install *irqbalance* (see: https://www.howtouselinux.com/post/linux-performance-irqbalance-service and https://openwrt.org/docs/guide-user/services/irqbalance)
* Remove unnecessary packages (Desktop) in Raspbian (https://virtualzone.de/posts/raspberry-pi-os-remove-packages/)

# <a id="sec">Security</a>
## OS

### AppArmor
* https://forums.raspberrypi.com/viewtopic.php?t=66748
* https://wiki.debian.org/AppArmor/HowToUse
* https://help.ubuntu.com/community/AppArmor
* https://wiki.archlinux.org/title/AppArmor 

### SELinux
**NOT TESTED**

## Firewall
### iptables/netfilter
### ufw
### firewalld
### apf (**NOT TESTED**)

## IDS / IPS
### Tripwire
### Suricata
### Fail2Ban


# <a id="paas">PaaS</a>
## Runtime Plattforms

### Docker
Installation on various OS (https://docs.docker.com/engine/install/). Often included in distribution package repositories.

### k3s / k3d
* https://rancher.com/docs/k3s/latest/en/quick-start/, needs at minimum RaspberryPI 3
* Installation is done via shell script (https://k3d.io/v5.2.2/#installation). Works on RaspberryPI 2 too, but very slow.

### minikube / kubernetes (k8s)
Installation is done via shell script (https://minikube.sigs.k8s.io/docs/start/). Works only on ARM64 (RaspberryPI 4) systems.

### MicroK8s
Ubuntu's own minikube (https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi)

### Podman
Installation on various OS (https://podman.io/getting-started/installation). Often included in distribution package repositories.

### nerdctl (**NOT TESTED**)
https://github.com/containerd/nerdctl

### DOKKU
see https://github.com/dokku/dokku. Some Buildpacks are not working on RaspberryPi2 (e.g. Herokuish)

### Caprover
see https://caprover.com/. SideNote: Caprover will not work properly if it is started in (rootless-)_podman_

## Rootless Container
see https://rootlesscontaine.rs/

### Docker (**NOT TESTED**)
Docker Rootless is not supported or available as package in Raspbian. Therefore you have to install and configure it manually:
* https://docs.docker.com/engine/security/rootless/
* https://linuxhandbook.com/rootless-docker/
* https://thenewstack.io/how-to-run-docker-in-rootless-mode/
* https://mohitgoyal.co/2021/04/14/going-rootless-with-docker-and-containers/

### Podman
* Remove all Podman and/or Container related packages from your installation (*apt purge podman slirp4netns crun runc buildah*), if you have already installed some from other (non Debian, e.g. https://software.opensuse.org/download.html?project=devel%3Akubic%3Alibcontainers%3Astable&package=podman) sources. Otherwise you will encounter some problems if you mix the packages from the repos.

* Install *uidmap* from the repo
```bash
$ sudo apt install uidmap
```

* Add a new user for rootless container. Username and groupname should be identical (otherwise it leads to some problems for subuid and subgid). Create the user with **no** password and **no** valid shell! DO NOT add the user to sudo group or to other system groups. The subuids and subgids should automatically be generated. If not, see https://rootlesscontaine.rs/getting-started/common/subuid/
```bash
$ sudo apt install adduser
$ sudo addgroup $GROUP
$ sudo adduser --home /home/$USER --shell /bin/nologin --ingroup $GROUP --disabled-password --disabled-login $USER
```

* Keep the deamons alive
```bash
$ sudo loginctl enable-linger $USER
```

* login to new $USER
```bash
$ sudo su --shell /bin/bash --login $USER
```

* Add BUS and XDG to .bashrc or ...
```bash
$ echo "export XDG_RUNTIME_DIR=/run/user/$UID" >> ~/.bashrc
$ echo "export DBUS_SESSION_BUS_ADDRESS=unix:path=${XDG_RUNTIME_DIR}/bus" >> ~/.bashrc
```
... set via systemctl (https://unix.stackexchange.com/questions/368730/starting-a-dbus-session-application-from-systemd-user-mode):
```bash
$ systemctl --user set-environment XDG_RUNTIME_DIR=/run/user/$UID
$ systemctl --user set-environment DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
```

* Install *podman* package and other packages from the repository
```bash
$ sudo apt install podman
```

* Enable podman socket for the current user
```bash
$ systemctl --user --now enable podman.socket
```

* Daemon restart
```bash
$ systemctl --user daemon-reload
```

* Test the unix socket and expect OK as reponse
```bash
$ curl --unix-socket /run/user/$UID/podman/podman.sock http://localhost/_ping
```

* If you have an older images, you have to migrate them to the new runtime (default is _crun_ on Debian)
```bash
$ podman system migrate --new-runtime crun
```

* If the containers will not start after migration, one trick is to delete all images and pull them again
```bash
$ podman system prune --all
```

* Logout from $USER
```bash
$ exit
```

* If there still some problems, review your configuration in _~/.config/containers/_ (if you have already one for $USER) or under _/etc/containers/_ and _/etc/containers/networks/_

### Configuration
* Copy the container and storage configuration to the $USER _~/.config_ directory
```bash
$ cp /usr/share/containers/containers.conf ~/.config/containers/
$ cp /usr/share/containers/storage.conf ~/.config/containers/
```

* Configure _containers.conf_ with
  * network_backend = "netavark" (the default container network stack)
  * runtime = "crun" (default runtime)
  * cgroup_manager = "systemd" (for usage with systemd)

* Configure _storage.conf_
  * driver = "overlay" (Default Storage Driver)
  * runroot = "/run/user/$UID/containers" (Temporary storage location)
  * mount_program = "/usr/bin/fuse-overlayfs" (Path to an helper program to use for mounting the file system, programm will be installed automatically by apt)

### Migrate from podman start to systemd start
Running podman containers can be started/stopped with systemd. To enable this, some commands have to be done for every container. This [script](https://github.com/Cub0n/RaspberryPI-and-Container-configurations/blob/main/migrateToSystemd.sh) makes it a little bit more automatic.
* https://linuxhandbook.com/autostart-podman-containers/

### Automatic Updates of containers
Every container (which should be automatically updated) needs a label="io.containers.autoupdate=registry".
* https://blog.arrogantrabbit.com/net/podman/
* https://linuxhandbook.com/update-podman-containers/
* or manually, see https://github.com/Cub0n/RaspberryPI-and-Container-configurations/blob/main/updateContainers.sh

### Further Documentation
* https://www.imaginarycloud.com/blog/podman-vs-docker/
* https://calinradoni.github.io/pages/210327-podman-systemd.html
* https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md
* https://linoxide.com/install-podman-on-debian/
* https://wiki.archlinux.org/title/Podman#Rootless_Podman
* https://developers.redhat.com/blog/2020/09/25/rootless-containers-with-podman-the-basics
* https://linuxhandbook.com/rootless-podman/
* https://www.tutorialworks.com/podman-rootless-volumes/
* https://howtoforge.com/how-to-install-podman-on-debian-11/
* https://blog.while-true-do.io/podman-encrypted-images/

# <a id="container">Images/Container and settings</a>
TODO
