# Media Server [![Build Status](https://travis-ci.org/IFeelFine/MediaServer.svg?branch=master)](https://travis-ci.org/IFeelFine/MediaServer)

This is a set of functions to install a media server within CentOS7. SELinux is enforcing, and this setup uses systemd for all services.

## Compatability
This installer has been tested on CentOS 7. CentOS 6 calls are very different (including the use of firewalld in Centos 7)

##
CentOS media server installation scripts. Includes Plex Media Server, Sonarr, Radarr, rTorrent, ruTorrent, Jackett, &amp; Tautulli

[x] CentOS 7.4
[ ] CentOS 6.x
[ ] Ubuntu (see Punk--Rock's script [here](https://github.com/Punk--Rock/Seedbox-installer/))

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
![(data:image/png;base64,data:image/png;base64,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](https://twitter.com/imdebating) [@imdebating](https://twitter.com/imdebating)