# FHEM Docker Base

This is a template for a docker based fhem installation with postgres.

**Change all the passwords for mySQL, FHEM, NodeRed, ...**

## Contains

- FHEM
- Postgres

## Requirements

- Docker
- Docker-Compose

## Install

```
git clone https://github.com/casoe/fhem-docker.git fhem-docker
cd fhem-docker
docker-compose up -d
```

## Defaults / Ports

- FHEM: http://[ip]:8083/fhem
