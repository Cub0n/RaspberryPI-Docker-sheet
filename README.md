# Contribution rules

If you want to contribute to this list, create a PR (Pull Request) with description what you are adding. The following rules should be addressed:

* Clear description
* Keep it simple and stupid (KISS
* Only use active open-source software and images
* Configuration/Enhancements have to be tested.

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
* In file /boot/cmdline.txt add cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 into the end of the file. (see: https://www.padok.fr/en/blog/raspberry-kubernetes)
* 

# <a id="sec">Security</a>
## OS
### Apparmor
### SELinux
## Network
## Firewall
## IDS / IPS
### Tripwire
### Suricata

# <a id="paas">PaaS</a>
## Runtime Plattforms
### Docker
Installation on various OS (https://docs.docker.com/engine/install/). Often included in distribution package repositories.
### k3s / k3d
* https://rancher.com/docs/k3s/latest/en/quick-start/, needs at minimum RaspberryPI 3
* Installation is done via shell script (https://k3d.io/v5.2.2/#installation). Works on RaspberryPI 2 too, but very slow.
### minikube / kuberntes (k8s)
Installation is done via shell script (https://minikube.sigs.k8s.io/docs/start/). Works only on ARM64 (RaspberryPI 4) systems.
### MicroK8s
Ubuntu own minikube (https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi)
### podman
Installation on various OS (https://podman.io/getting-started/installation). Often included in distribution package repositories.
### nerdctl
... todo

## Rootless Container


# <a id="container">Images/Container and settings</a>
