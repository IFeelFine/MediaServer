# Media Server [![Build Status](https://travis-ci.org/IFeelFine/MediaServer.svg?branch=master)](https://travis-ci.org/IFeelFine/MediaServer)

This is a set of functions to install a media server within CentOS7. SELinux is enforcing, and this setup uses systemd for all services.

## Compatability
This installer has been tested on CentOS 7. CentOS 6 calls are very different (including the use of firewalld in Centos 7)

##
CentOS media server installation scripts. Includes Plex Media Server, Sonarr, Radarr, rTorrent, ruTorrent, Jackett, &amp; Tautulli

* [x] CentOS 7.4
* [ ] CentOS 6.x
* [ ] Ubuntu (see Punk--Rock's script [here](https://github.com/Punk--Rock/Seedbox-installer/))

## Services

| Service | Installation | Installed via | Version | Port |
| --- |:---:| --- |:---:| --- |
| Plex Media Server | Installed | Yum repository | [latest](https://www.plex.tv/downloads/) | 32400 |
| Sonarr | Installed | Sonarr website | [latest](https://github.com/Sonarr/Sonarr/releases) | 8989 |
| Radarr | Installed | GitHub | [latest](https://github.com/Radarr/Radarr/releases) | 7878 |
| rTorrent + ruTorrent (on Nginx) | Installed     | Yum repository | [latest](https://github.com/Novik/ruTorrent/releases) | 8080 |
| Jackett | Installed | GitHub | [latest](https://github.com/Jackett/Jackett/releases) | 9117 |
| Tautulli | Installed | GitHub | [latest](https://github.com/Tautulli/Tautulli) | 8181 |

## Installation
Download the `autoinstall.sh` script to launch the installer.
```shell
wget -O - https://raw.githubusercontent.com/IFeelFine/MediaServer/master/autoinstall.sh | sh 
```

## To-Do
- Refine SELinux security contexts

## License
Copyright (c)2018 I Feel Fine Inc. 
[MIT License](https://opensource.org/licenses/MIT)

## Contact
[![twitter](https://png.icons8.com/metro/50/000000/twitter.png)](https://twitter.com/imdebating/)[@imdebating](https://twitter.com/imdebating)