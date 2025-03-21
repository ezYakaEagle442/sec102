
# OpenVAS Install

Read:
- [GitHub docss](https://github.com/greenbone/openvas-scanner?tab=readme-ov-file#docker-greenbone-community-containers)
- [https://greenbone.github.io/docs/latest/22.4/container/](https://greenbone.github.io/docs/latest/22.4/container/)
- []()
- []()
- []()
- []()



## Install Docker

Read :
- [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
- [https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script) 

```bash
sudo apt install bind9-dnsutils
sudo apt  install jq

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# check docker version
docker -v

sudo groupadd docker
sudo usermod -aG docker $USER

sudo apt install ca-certificates curl gnupg
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Setup Docker-Compose


```bash
export DOWNLOAD_DIR=$HOME/greenbone-community-container && mkdir -p $DOWNLOAD_DIR

curl -f -O -L https://greenbone.github.io/docs/latest/_static/docker-compose.yml --output-dir "$DOWNLOAD_DIR"
docker compose -f $DOWNLOAD_DIR/docker-compose.yml pull

curl -O https://greenbone.github.io/docs/latest/_static/docker-compose.yml
sha256sum docker-compose.yml
```
```console
00a35854a824a52a246b34c32a159cbcb200d5819d3a7100a6dfac53657f36b4
```



```bash
# depuis https://greenbone.github.io/docs/latest/_static/docker-compose.yml :
# est un lien symobique vers https://github.com/greenbone/docs/blob/main/src/_static/docker-compose-22.4.yml 
git clone https://github.com/greenbone/docs.git 
cd docs

# récupérer le HASH SHA-1 du commit
git log -n 1 --pretty=format:"%H" -- src/_static/docker-compose-22.4.yml
git show d57f68bd96cc64782ffa5745ed189bc2c0e3d38d:src/_static/docker-compose-22.4.yml | sha256sum
```

```console
00a35854a824a52a246b34c32a159cbcb200d5819d3a7100a6dfac53657f36b4
```

L’éditeur a confirmé avoir migré ses images de DockerHub vers leur Registry privé.
https://forum.greenbone.net/t/new-registry-community-container/19069

```bash
curl -k https://registry.community.greenbone.net/v2/_catalog | jq -r '.repositories[]' > images_list.txt
```

```console
community/cert-bund-data
community/data-objects
community/dfn-cert-data
community/gpg-data
community/greenbone-feed-sync
community/gsa
community/gsad
community/gvm-libs
community/gvm-tools
community/gvmd
community/mqtt-broker
community/notus-data
community/openvas-scanner
community/openvas-smb
community/ospd-openvas
community/pg-gvm
community/redis-server
community/report-formats
community/scap-data
community/vulnerability-tests
```


```bash
docker compose -f $DOWNLOAD_DIR/docker-compose.yml up -d
docker compose -f $DOWNLOAD_DIR/docker-compose.yml \
    exec -u gvmd gvmd gvmd --user=admin --new-password='SuperMotDePasse'
```

Now, open your browser and go the OpenVAS console at http://127.0.0.1:9392


```bash
docker compose -f $DOWNLOAD_DIR/docker-compose.yml pull
docker compose -f $DOWNLOAD_DIR/docker-compose.yml up -d

# Télécharger les Flux de vulnérabilités ( Feeds) :
docker compose -f $DOWNLOAD_DIR/docker-compose.yml pull notus-data vulnerability-tests scap-data dfn-cert-data cert-bund-data report-formats data-objects

# Montez les données dans un volume :
docker compose -f $DOWNLOAD_DIR/docker-compose.yml up -d notus-data vulnerability-tests scap-data dfn-cert-data cert-bund-data report-formats data-objects
```

```console

```

```bash
docker ps |  grep ospd-openvas
docker logs -f 9f61f7774fda
docker ps | grep gvmd

docker inspect a7f1e726c518 | jq -c '.[0].Name'
docker exec greenbone-community-edition-openvas-1  /bin/ls -al
docker exec -it greenbone-community-edition-openvas-1 /bin/sh

```


```bash
docker compose -f $DOWNLOAD_DIR/docker-compose.yml run --rm gvm-tools
gvm-cli --gmp-username admin socket --pretty --xml "<get_version/>"

```

```console

```

```bash

```

```console

```


```bash
docker logs -f 615e424be483 | grep "No SCAP database found for migration"
docker logs -f 615e424be483 | grep "No CERT database found for migration"
docker logs -f 615e424be483 | grep "Port list All IANA assigned TCP"
docker logs -f 615e424be483 | grep "Port list All TCP and Nmap top 100 UDP"
docker logs -f 615e424be483 | grep "Report format XML"
docker logs -f 615e424be483 | grep "update_scap: Updating data from feed"
docker logs -f 615e424be483 | grep "sync_cert: Updating CERT info succeeded"
docker logs -f 615e424be483 | grep "Scan config Full and fast"
docker logs -f 615e424be483 | grep "docker logs -f 615e424be483 | grep update_scap"
docker logs -f 615e424be483 | grep "sync_cert: Updating data from feed"
docker logs -f 615e424be483 | grep "Updating VTs in database"
```

```console

```



```bash
docker logs -f 615e424be483 | grep "grep update_scap"

docker logs -f 615e424be483 | grep ""
```

```console

```


