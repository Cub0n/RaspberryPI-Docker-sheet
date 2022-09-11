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
* https://github.com/containerd/nerdctl

### DOKKU (**NOT TESTED**)
* https://github.com/dokku/dokku

## Rootless Container
see https://rootlesscontaine.rs/

### Docker (**NOT TESTED**)
Docker Rootless is not supported or available as package in Raspbian. Therefore you have to install and configure it manually:
* https://docs.docker.com/engine/security/rootless/
* https://linuxhandbook.com/rootless-docker/
* https://thenewstack.io/how-to-run-docker-in-rootless-mode/
* https://mohitgoyal.co/2021/04/14/going-rootless-with-docker-and-containers/

### Podman
The podman package in the distributiuon repository works, but user sockets were not supported properly or have bugs. So install a newer version from a third party repo.

* Remove all Podman and/or Container related packages from your installation (*apt purge podman slirp4netns*), if you have already installed some. Otherwise you will encounter some problems if you mix the packages from the repos.

* Add new repository described [here](https://software.opensuse.org/download.html?project=devel%3Akubic%3Alibcontainers%3Astable&package=podman). Raspbian is based on [Debian 11 / Bullseye](https://www.debian.org/releases/stable/), so choose Debian 11 directly. **NOT TESTED**: Raspbian 10 could also work: the package and version is the same here.

* Install *podman-rootless* package from the repository
```bash
$ sudo apt install podman-rootless
```

* Install *uidmap* from the repo
```bash
$ sudo apt install uidmap
```

* Add a new user for rootless container. Username and groupname should be identical (otherwise it leads to some problems for subuid and subgid). Create the user with **no** password and **no** valid shell! DO NOT add the user to sudo group or to other system groups. The subuids and subgids should automatically be generated, if not see https://rootlesscontaine.rs/getting-started/common/subuid/
```bash
$ sudo apt install adduser
$ sudo addgroup $GROUP
$ sudo adduser --home /home/$USER --shell /bin/nologin --ingroup $GROUP --disabled-password --disabled-login $USER
```

* login to new $USER
```bash
$ sudo su --shell /bin/bash --login $USER
```

* Add BUS and XDG to .bashrc
```bash
$ echo "export XDG_RUNTIME_DIR=/run/user/$UID" >> ~/.bashrc
$ echo "export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus" >> ~/.bashrc
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
$ curl --unix-socket /run/user/1000/podman/podman.sock http://localhost/_ping
```

* Logout $USER
* Keep the socket alive 
```bash
$ sudo loginctl enable-linger $USER
```

* Configuration: TODO

Further Documentation
* https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md
* https://linoxide.com/install-podman-on-debian/
* https://wiki.archlinux.org/title/Podman#Rootless_Podman
* https://howtoforge.com/how-to-install-podman-on-debian-11/

# <a id="container">Images/Container and settings</a>
TODO
