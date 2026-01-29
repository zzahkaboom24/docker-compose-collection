## List of services available:
<img src="https://img.shields.io/badge/Availables:_96-%2354B848.svg?style=for-the-badge&logo=cachet&logoColor=white">

| Status | Service | Website | Update | Maintainer |
|:--:|--|--|--|--|
| ✅ | <img src="https://img.papamica.com/logo/adminer.png" alt="adminer" width="20"/> [npm](https://github.com/zzahkaboom24/docker-compose-collection/blob/master/composes-files/nginx-proxy-manager/docker-compose.yml) | [nginxproxymanager.com](https://nginxproxymanager.com/) | 28-01-2026 | zzahkaboom24 |
| ✅ | <img src="https://img.papamica.com/logo/adminer.png" alt="adminer" width="20"/> [simplelogin](https://github.com/zzahkaboom24/docker-compose-collection/blob/master/composes-files/simplelogin/docker-compose.yml) | [simplelogin.io](https://simplelogin.io/) | 28-01-2026 | zzahkaboom24 |
</div>

---
# Utilisation
## Portainer
Add this URL in Portainer:

```
https://raw.githubusercontent.com/PAPAMICA/docker-compose-collection/master/templates-portainer.json
```

![PORTAINER](https://i.imgur.com/M49ssCN.png)

## Debian
Install Git :
```bash
apt install -y git
```

Clone repo
```bash
git clone https://github.com/PAPAMICA/docker-compose-collection/
```


Configuration of variables and execution of a docker-compose:
```bash
cd docker-compose-collection
nano .env
sudo docker-compose -f service.yml --env-file .env up -d
```
## Some useful commands:

-   **docker container ls** : Show current Docker containers
-   **docker-compose stop** : Stop the containers created with the scripts (in the script folder)
-   **docker-compose up -d** : Launch the containers created with the scripts (in the script folder)
-   **docker logs -f <id_container>** : Display the container logs
-   **docker exec -it <id_container> bash** : Start a shell in container

---
# Add new docker-compose file
I automated the creation of the json template file for Portainer and the update of the README.md.

If you want to add a new docker-compose, you must use the following template:
```yaml
# Maintainer: Mickael "PAPAMICA" Asseline
# Update: 2022-05-10

#& type: 3
#& title: Hastebin
#& description: Share your code easily
#& note: Website: <a href='https://hastebin.com/about.md' target='_blank' rel='noopener'>Hastebin.com</a>
#& categories: SelfHosted, PAPAMICA
#& platform: linux
#& logo: https://progsoft.net/images/hastebin-icon-b45e3f5695d3f577b2630648bd00584195822e3d.png

#% SERVICE: Name of the service (No spaces or points) [hastebin]
#% DATA_LOCATION: Data localization (Example: /apps/service) [/_data/apps]
#% URL: Service URL (Example: service.papamica.fr or service.com)
#% NETWORK: Your Traefik network (Example: proxy) [proxy]

# Work with Portainer
version: "2"
services:
  # Hastebin : https://hastebin.com/about.md
  hastebin:
    image: rlister/hastebin:latest
    container_name: $SERVICE
    restart: always
    environment:
      STORAGE_TYPE: file
    volumes:
      - $DATA_LOCATION/$SERVICE/data:/data
    healthcheck:
      test: wget -s 'http://localhost:7777'
      interval: 1m
      timeout: 30s
      retries: 3
    networks:
      - default
    labels:
      - "autoupdate=monitor" # https://github.com/PAPAMICA/container-updater
      - "traefik.enable=true"
      - "traefik.http.routers.$SERVICE.entrypoints=https"
      - "traefik.http.routers.$SERVICE.rule=Host(`$URL`)"
      - "traefik.http.routers.$SERVICE.tls=true"
      - "traefik.http.routers.$SERVICE.tls.certresolver=http"
      - "traefik.docker.network=$NETWORK"

networks:
  default:
    external:
      name: $NETWORK
```
