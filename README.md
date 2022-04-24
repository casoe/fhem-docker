# FHEM Docker Base

This is a template for a docker based FHEM installation with Postgres.

## Contains

- FHEM
- Postgres

## Requirements

- Docker
- Docker-Compose (V2, Docker API Plugin)

## Install

```
git clone https://github.com/casoe/fhem-docker.git fhem-docker
cd fhem-docker
docker-compose up -d
```

### Restore DB-Dump

```
docker exec -i fhem-docker-postgres-1 pg_restore -Fc -v --clean -h localhost -U fhem -d fhem < dump.sqlc
```

## Defaults / Ports

- FHEM: http://[ip]:8083/fhem
